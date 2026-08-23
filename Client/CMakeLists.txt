add_executable(Marla.Client
    src/main.cpp
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set_target_properties(Marla.Client PROPERTIES
        CXX_STANDARD 26
        CXX_STANDARD_REQUIRED ON
    )
    target_compile_options(Marla.Client PRIVATE /std:c++latest)
else()
    target_compile_features(Marla.Client PRIVATE cxx_std_26)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND CMAKE_GENERATOR MATCHES "^Visual Studio")
    # Visual Studio generators cannot consume CMake's imported std-module
    # target, so compile the MSVC module interfaces directly into the client.
    get_filename_component(_msvc_compiler_dir "${CMAKE_CXX_COMPILER}" DIRECTORY)
    get_filename_component(_msvc_toolset_dir "${_msvc_compiler_dir}/../../.." ABSOLUTE)
    set(_msvc_modules_dir "${_msvc_toolset_dir}/modules")

    if(NOT EXISTS "${_msvc_modules_dir}/std.ixx")
        message(FATAL_ERROR "Could not find the MSVC standard-library modules in ${_msvc_modules_dir}")
    endif()

    target_sources(Marla.Client
        PRIVATE
            FILE_SET msvc_std_modules TYPE CXX_MODULES
            BASE_DIRS "${_msvc_modules_dir}"
            FILES
                "${_msvc_modules_dir}/std.ixx"
                "${_msvc_modules_dir}/std.compat.ixx"
    )
else()
    set_property(TARGET Marla.Client PROPERTY CXX_MODULE_STD ON)
endif()

target_link_libraries(Marla.Client PRIVATE Marla.Core)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_link_libraries(Marla.Client PRIVATE stdc++exp)
endif()

include(cmake/dependencies/GLAD.cmake)
include(cmake/dependencies/GLFW.cmake)
