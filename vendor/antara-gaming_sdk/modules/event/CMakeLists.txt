## shared sources between the module and his unit tests
add_library(antara_event_shared_sources STATIC)
target_sources(antara_event_shared_sources PRIVATE
        antara/gaming/event/quit.game.cpp
        antara/gaming/event/fatal.error.cpp)
target_include_directories(antara_event_shared_sources PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(antara_event_shared_sources PUBLIC
        antara::default_settings
        doom::meta
        antara::entt
        antara::refl-cpp
        antara::core)
add_library(antara::event ALIAS antara_event_shared_sources)

