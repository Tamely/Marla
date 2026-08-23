add_library(glad STATIC
    "${CMAKE_CURRENT_LIST_DIR}/../../vendor/glad/src/glad.c"
)
add_library(glad::glad ALIAS glad)

target_include_directories(glad
    PUBLIC
        "${CMAKE_CURRENT_LIST_DIR}/../../vendor/glad/include"
)

target_link_libraries(Marla.Client PRIVATE glad::glad)
