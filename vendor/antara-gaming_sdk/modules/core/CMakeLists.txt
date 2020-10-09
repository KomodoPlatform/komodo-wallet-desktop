##! shared sources between the module and his unit tests
find_package(Boost REQUIRED COMPONENTS filesystem)

add_library(antara_core_shared_sources STATIC)
target_sources(antara_core_shared_sources PRIVATE antara/gaming/core/real.path.cpp antara/gaming/core/api.scaling.cpp
        $<$<PLATFORM_ID:Darwin>:antara/gaming/core/details/osx/api.scaling.mm>
        )
if (APPLE)
    find_library(APPLE_FOUNDATION_FRAMEWORK_LIBRARY Foundation)
    find_path(APPLE_FOUNDATION_FRAMEWORK_INCLUDE_DIR NAMES NSBundle.h)
    mark_as_advanced(APPLE_FOUNDATION_FRAMEWORK_LIBRARY APPLE_FOUNDATION_FRAMEWORK_INCLUDE_DIR)
endif ()
target_include_directories(antara_core_shared_sources PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} $<$<PLATFORM_ID:Darwin>:${APPLE_FOUNDATION_FRAMEWORK_INCLUDE_DIR}>)
target_link_libraries(antara_core_shared_sources PUBLIC
        antara::default_settings
        antara::entt
        antara::refl-cpp
        Boost::filesystem
        PRIVATE
        $<$<PLATFORM_ID:Darwin>:${APPLE_FOUNDATION_FRAMEWORK_LIBRARY}>)
if (APPLE)
    target_link_libraries(antara_core_shared_sources PRIVATE "-framework AppKit")
endif ()
add_library(antara::core ALIAS antara_core_shared_sources)

if (CMAKE_VERSION VERSION_GREATER 3.15)
    set_target_properties(antara_core_shared_sources PROPERTIES UNITY_BUILD ON)
    set_source_files_properties(antara/gaming/core/details/osx/api.scaling.mm PROPERTIES SKIP_PRECOMPILE_HEADERS ON)
    set_property(SOURCE antara/gaming/core/details/osx/api.scaling.mm PROPERTY SKIP_UNITY_BUILD_INCLUSION ON)
    set_source_files_properties(antara/gaming/core/details/osx/api.scaling.mm PROPERTIES SKIP_UNITY_BUILD_INCLUSION ON)
endif ()