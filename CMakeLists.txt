cmake_minimum_required(VERSION 4.3)

# CMake's import-std support is still gated by a version-specific UUID.
# This must be set before CXX is enabled by project().
if(CMAKE_VERSION VERSION_LESS "4.4")
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "451f2fe2-a8a2-47c3-bc32-94786d8fc91b")
else()
    set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "f35a9ac6-8463-4d38-8eec-5d6008153e7d")
endif()

project(Marla LANGUAGES C CXX)

set(CMAKE_CXX_EXTENSIONS OFF)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # CMake 4.3 does not model MSVC's C++26 mode yet. Teach its module
    # machinery that /std:c++latest is the compiler's C++26 mode.
    set(CMAKE_CXX26_STANDARD_COMPILE_OPTION "/std:c++latest")
    set(CMAKE_CXX26_EXTENSION_COMPILE_OPTION "/std:c++latest")
    set(CMAKE_CXX_STANDARD_LATEST 26)
    set(CMAKE_CXX26_COMPILE_FEATURES cxx_std_26)
    list(APPEND CMAKE_CXX_COMPILE_FEATURES cxx_std_26)
    list(REMOVE_DUPLICATES CMAKE_CXX_COMPILE_FEATURES)

    if(23 IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD)
        list(APPEND CMAKE_CXX_COMPILER_IMPORT_STD 26)
        list(REMOVE_DUPLICATES CMAKE_CXX_COMPILER_IMPORT_STD)
    endif()
endif()

if(CMAKE_CONFIGURATION_TYPES)
    list(APPEND CMAKE_CONFIGURATION_TYPES Shipping)
    list(REMOVE_DUPLICATES CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES}" CACHE STRING "" FORCE)
else()
    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build configuration" FORCE)
    endif()
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release Shipping)
endif()

add_compile_definitions("$<$<CONFIG:Shipping>:NDEBUG>")

if(MSVC)
    add_compile_options(
        "$<$<CONFIG:Debug>:/Od>"
        "$<$<CONFIG:Release>:/O2>"
        "$<$<CONFIG:Release>:/Zi>"
        "$<$<CONFIG:Shipping>:/O2>"
    )
    add_link_options(
        "$<$<CONFIG:Release>:/DEBUG:FULL>"
        "$<$<CONFIG:Shipping>:/OPT:REF>"
        "$<$<CONFIG:Shipping>:/OPT:ICF>"
    )
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(
        "$<$<CONFIG:Debug>:-O0>"
        "$<$<CONFIG:Debug>:-g>"
        "$<$<CONFIG:Release>:-O3>"
        "$<$<CONFIG:Release>:-g>"
        "$<$<CONFIG:Shipping>:-O3>"
        "$<$<CONFIG:Shipping>:-g0>"
    )
    add_link_options("$<$<CONFIG:Shipping>:-s>")
endif()

add_subdirectory(Core)
add_subdirectory(Client)
