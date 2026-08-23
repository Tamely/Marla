add_library(Marla.Core STATIC)

target_sources(Marla.Core
    PRIVATE
        src/Marla.Core.cpp
    PUBLIC
        FILE_SET CXX_MODULES
        BASE_DIRS src
        FILES src/Marla.Core.cppm
)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set_target_properties(Marla.Core PROPERTIES
        CXX_STANDARD 26
        CXX_STANDARD_REQUIRED ON
    )
    target_compile_options(Marla.Core PUBLIC /std:c++latest)
else()
    target_compile_features(Marla.Core PUBLIC cxx_std_26)
endif()
