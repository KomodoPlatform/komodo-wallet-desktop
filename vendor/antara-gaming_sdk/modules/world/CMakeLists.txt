## shared sources between the module and his unit tests
add_library(antara_world_shared_sources STATIC)
target_sources(antara_world_shared_sources PRIVATE antara/gaming/world/world.app.cpp)
target_include_directories(antara_world_shared_sources PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(antara_world_shared_sources PUBLIC antara::core antara::ecs)
add_library(antara::world ALIAS antara_world_shared_sources)