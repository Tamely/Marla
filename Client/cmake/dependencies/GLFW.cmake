include(FetchContent)

set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)

FetchContent_Declare(glfw
    URL "https://github.com/glfw/glfw/releases/download/3.5.1/glfw-3.5.1.zip"
    URL_HASH "SHA256=EA79BC5FEFFC254C87291980C2D0BCE9ACEBB68C4983B79F961DCD2CB8A611A0"
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    EXCLUDE_FROM_ALL
)

FetchContent_MakeAvailable(glfw)

if(NOT TARGET glfw)
    message(FATAL_ERROR "GLFW was downloaded but did not create the expected glfw target")
endif()

set(_glfw_include_dir "${glfw_SOURCE_DIR}/include")
if(NOT EXISTS "${_glfw_include_dir}/GLFW/glfw3.h")
    message(FATAL_ERROR "GLFW was downloaded but GLFW/glfw3.h was not found in ${_glfw_include_dir}")
endif()

if(NOT TARGET glfw::glfw)
    add_library(glfw::glfw ALIAS glfw)
endif()

# Keep this explicit on the client so generated IDE projects and compilation
# databases expose GLFW even when they do not inspect transitive target usage.
target_include_directories(Marla.Client PRIVATE "${_glfw_include_dir}")
target_link_libraries(Marla.Client PRIVATE glfw::glfw)
