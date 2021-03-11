add_library(antara_app_net INTERFACE)

target_include_directories(antara_app_net INTERFACE ${CMAKE_CURRENT_LIST_DIR})

add_library(antara::app::net ALIAS antara_app_net)