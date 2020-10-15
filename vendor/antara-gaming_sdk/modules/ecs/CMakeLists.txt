## shared sources between the module and his unit tests
add_library(antara_ecs_shared_sources STATIC)
target_sources(antara_ecs_shared_sources PRIVATE
        antara/gaming/ecs/base.system.cpp
        antara/gaming/ecs/system.manager.cpp
        antara/gaming/ecs/event.add.base.system.cpp)
target_include_directories(antara_ecs_shared_sources PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(antara_ecs_shared_sources PUBLIC
        antara::core
        antara::entt
        strong_type
        expected
        range-v3::range-v3
        antara::default_settings
        antara::timer
        antara::event
        doom::meta)
add_library(antara::ecs ALIAS antara_ecs_shared_sources)

if (CMAKE_VERSION VERSION_GREATER 3.15)
    set_target_properties(antara_ecs_shared_sources PROPERTIES UNITY_BUILD ON)
endif ()