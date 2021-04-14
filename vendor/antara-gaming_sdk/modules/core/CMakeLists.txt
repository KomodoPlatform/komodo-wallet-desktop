##! shared sources between the module and his unit tests
find_package(Boost REQUIRED COMPONENTS filesystem)

add_library(antara_core_shared_sources STATIC)
target_sources(antara_core_shared_sources PRIVATE antara/gaming/core/real.path.cpp antara/gaming/core/api.scaling.cpp
        antara/gaming/core/security.authentification.cpp
        $<$<PLATFORM_ID:Darwin>:antara/gaming/core/details/osx/api.scaling.mm>
        $<$<PLATFORM_ID:Darwin>:antara/gaming/core/details/osx/security.authentification.mm>
        $<$<PLATFORM_ID:Windows>:antara/gaming/core/details/windows/security.authentification.cpp>
        )
if (APPLE)
    macro(antara_add_framework fwname appname)
        find_library(FRAMEWORK_${fwname}
                NAMES ${fwname}
                PATHS ${CMAKE_OSX_SYSROOT}/System/Library
                PATH_SUFFIXES Frameworks
                NO_DEFAULT_PATH)
        if( ${FRAMEWORK_${fwname}} STREQUAL FRAMEWORK_${fwname}-NOTFOUND)
            MESSAGE(ERROR ": Framework ${fwname} not found")
        else()
            TARGET_LINK_LIBRARIES(${appname} PRIVATE ${FRAMEWORK_${fwname}})
            MESSAGE(STATUS "Framework ${fwname} found at ${FRAMEWORK_${fwname}}")
        endif()
    endmacro()
endif ()
target_include_directories(antara_core_shared_sources PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} $<$<PLATFORM_ID:Darwin>:${APPLE_FOUNDATION_FRAMEWORK_INCLUDE_DIR}>)
target_link_libraries(antara_core_shared_sources PUBLIC
        antara::default_settings
        antara::entt
        antara::refl-cpp
        Boost::filesystem
        PRIVATE
        #$<$<PLATFORM_ID:Darwin>:${APPLE_FOUNDATION_FRAMEWORK_LIBRARY}>
        )
if (APPLE)
    antara_add_framework(AppKit antara_core_shared_sources)
    antara_add_framework(Foundation antara_core_shared_sources)
    antara_add_framework(LocalAuthentication antara_core_shared_sources)
endif ()
add_library(antara::core ALIAS antara_core_shared_sources)

if (CMAKE_VERSION VERSION_GREATER 3.15)
    set_target_properties(antara_core_shared_sources PROPERTIES UNITY_BUILD ON)
    set_source_files_properties(
            antara/gaming/core/details/osx/api.scaling.mm
            antara/gaming/core/details/osx/security.authentification.mm
            PROPERTIES
            SKIP_PRECOMPILE_HEADERS
            ON)
    set_property(SOURCE antara/gaming/core/details/osx/api.scaling.mm antara/gaming/core/details/osx/security.authentification.mm PROPERTY SKIP_UNITY_BUILD_INCLUSION ON)
    set_source_files_properties(antara/gaming/core/details/osx/api.scaling.mm antara/gaming/core/details/osx/security.authentification.mm PROPERTIES SKIP_UNITY_BUILD_INCLUSION ON)
endif ()
