## shared sources between the module and his unit tests
add_library(antara_timer_shared_sources STATIC)
target_sources(antara_timer_shared_sources PRIVATE antara/gaming/timer/time.step.cpp)
target_include_directories(antara_timer_shared_sources PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(antara_timer_shared_sources PUBLIC antara::default_settings)
add_library(antara::timer ALIAS antara_timer_shared_sources)