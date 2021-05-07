cmake_minimum_required(VERSION 3.15)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(project.metadata)           ##> generate_dex_project_metafiles()
generate_dex_project_metafiles()

include(build_type)
include(compiler_prerequisites)
include(vcpkg_prerequisites)
include(qt_prerequisites)
include(cfg_hash)

project(${DEX_PROJECT_NAME} LANGUAGES CXX VERSION 0.4.2)
message(STATUS "${PROJECT_NAME} is version ${PROJECT_VERSION}")

include(cmake_default_options)
include(ipo_prerequisites)

##! Options
option(PREFER_BOOST_FILESYSTEM "Enable to use boost filesystem instead of std::filesystem" OFF)
option(WITH_HOTRELOAD "Enable to use qml Hot reload" OFF)

if (NOT WITH_HOTRELOAD)
    message(STATUS "Hot Reload is not active download SortFilterProxyModel")
    include(FetchContent)

    set(SFPM_REPOSITORY "https://github.com/OlivierLDff/SortFilterProxyModel.git" CACHE STRING "SortFilterProxyModel repository url")
    set(SFPM_TAG master CACHE STRING "SortFilterProxyModel git tag")

    FetchContent_Declare(
            SortFilterProxyModel
            GIT_REPOSITORY ${SFPM_REPOSITORY}
            GIT_TAG        ${SFPM_TAG}
            GIT_SHALLOW    1
    )

    set(SFPM_FOLDER_PREFIX "Dependencies" CACHE STRING "Prefix folder for all SortFilterProxyModel generated targets in generated project (only decorative)")
    FetchContent_MakeAvailable(SortFilterProxyModel)
endif()

##! Antara
include(antara)
##! Calling this macros provided by the sdk will if you are on Apple init the environment for this OS (std::filesystem).
init_antara_env()


##! We include the module from CMake for fetching dependencies
include(FetchContent)

if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    set(LINUX TRUE)
endif ()

if (UNIX AND NOT APPLE)
    message("Forcing stdlib C++")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++abi")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
endif ()

##! We fetch our dependencies
if (APPLE)
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.1.3358/mm2-2b3db4f49-Darwin-Release.zip)
elseif (UNIX AND NOT APPLE)
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.1.3358/mm2-2b3db4f49-Linux-Release.zip)
else ()
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.1.3358/mm2-2b3db4f49-Windows_NT-Release.zip)
endif ()

FetchContent_Declare(qmaterial URL https://github.com/KomodoPlatform/Qaterial/archive/last-clang-working-2.zip)

FetchContent_Declare(jl777-coins
        URL https://github.com/KomodoPlatform/coins/archive/master.zip)

#FetchContent_Declare(adex-generics-coins
#        URL https://github.com/KomodoPlatform/atomicdex-desktop-generics/archive/main.zip)

FetchContent_MakeAvailable(mm2 jl777-coins qmaterial)

##! Configure our needs.
if (UNIX)
    configure_file(assets/config/${PROJECT_VERSION}-coins.json ${CMAKE_CURRENT_SOURCE_DIR}/assets/config/${PROJECT_VERSION}-coins.json COPYONLY)
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2 ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/mm2 COPYONLY)
else ()
    configure_file(assets/config/${PROJECT_VERSION}-coins.json ${CMAKE_BINARY_DIR}/bin/assets/config/${PROJECT_VERSION}-coins.json COPYONLY)
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2.exe ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/mm2.exe COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/msvcp140.dll ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/msvcp140.dll COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/msvcr100.dll ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/msvcr100.dll COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/vcruntime140.dll ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/vcruntime140.dll COPYONLY)
endif ()

add_subdirectory(vendor/antara-gaming_sdk/modules)

##! Osx bundle icon
set(ICON)
configure_icon_osx(${CMAKE_CURRENT_SOURCE_DIR}/cmake/install/macos/dex-logo.icns ICON dex-logo.icns)
##! End antara

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

add_subdirectory(src)

# Adds Qaterial hot reload to main executable
if (WITH_HOTRELOAD)
    message(STATUS "Hot reload enabled")
    include(hot_reload/cmake/Configuration.cmake)
    include(hot_reload/cmake/FetchDependencies.cmake)
    set(QATERIALHOTRELOAD_LIB QaterialHotReload)
    set(QATERIALHOTRELOAD_SRC_DIR ${CMAKE_SOURCE_DIR}/hot_reload/src/Qaterial/HotReload)
    add_subdirectory(hot_reload/qml/Qaterial/HotReload)

    add_library(${QATERIALHOTRELOAD_LIB} STATIC
            ${QATERIALHOTRELOAD_SRC_DIR}/HotReload.hpp
            ${QATERIALHOTRELOAD_SRC_DIR}/HotReload.cpp
            ${QATERIALHOTRELOAD_QML_RES})
    add_library(Qaterial::HotReload ALIAS ${QATERIALHOTRELOAD_LIB})

    target_link_libraries(${QATERIALHOTRELOAD_LIB} PUBLIC
            Qaterial
            SortFilterProxyModel
            )
    target_link_libraries(${QATERIALHOTRELOAD_LIB} PRIVATE
            Qaterial::HotReload::Ui
            spdlog::spdlog
            )

    function(target_link_quiet_libraries TARGET)
        foreach (LIB ${ARGN})
            if (TARGET ${LIB})
                target_link_libraries(${TARGET} PUBLIC ${LIB})
            endif ()
        endforeach (LIB)
    endfunction()

    # Optionnal Qt libs that might be interessant to have packaged with hotreloader
    find_package(Qt5 QUIET COMPONENTS
            Charts)

    target_link_quiet_libraries(${QATERIALHOTRELOAD_LIB}
            Qt::Charts)

    set_target_properties(${QATERIALHOTRELOAD_LIB} PROPERTIES
            FOLDER ${QATERIALHOTRELOAD_FOLDER_PREFIX}
            AUTORCC TRUE
            AUTOMOC TRUE)
    target_include_directories(${QATERIALHOTRELOAD_LIB} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/hot_reload/src)
    target_compile_definitions(${QATERIALHOTRELOAD_LIB}
            PRIVATE -DQATERIALHOTRELOAD_VERSION_MAJOR=${QATERIALHOTRELOAD_VERSION_MAJOR}
            PRIVATE -DQATERIALHOTRELOAD_VERSION_MINOR=${QATERIALHOTRELOAD_VERSION_MINOR}
            PRIVATE -DQATERIALHOTRELOAD_VERSION_PATCH=${QATERIALHOTRELOAD_VERSION_PATCH}
            PRIVATE -DQATERIALHOTRELOAD_VERSION_TAG=${QATERIALHOTRELOAD_VERSION_TAG}
            PRIVATE -DQATERIALHOTRELOAD_VERSION_TAG_HEX=${QATERIALHOTRELOAD_VERSION_TAG_HEX}
            )

    if (QATERIALHOTRELOAD_ENABLE_PCH AND COMMAND target_precompile_headers)
        target_precompile_headers(${QATERIALHOTRELOAD_LIB} PRIVATE ${PROJECT_SOURCE_DIR}/hot_reload/src/Qaterial/HotReload/Pch/Pch.hpp)
    endif ()

    get_target_property(QT_TARGET_TYPE Qt::Core TYPE)
    if (${QT_TARGET_TYPE} STREQUAL "STATIC_LIBRARY")
        qt_generate_qml_plugin_import(${QATERIALHOTRELOAD_LIB} QML_SRC ${CMAKE_CURRENT_SOURCE_DIR})
        qt_generate_plugin_import(${QATERIALHOTRELOAD_LIB})
    endif ()

    target_link_libraries(${PROJECT_NAME} PUBLIC Qaterial::HotReload)
    target_compile_definitions(${PROJECT_NAME} PUBLIC ATOMICDEX_HOT_RELOAD)
endif ()

add_library(antara_qrcode STATIC)
target_sources(antara_qrcode PRIVATE vendor/qrcode/QrCode.cpp)
target_include_directories(antara_qrcode PUBLIC vendor/qrcode)
target_link_libraries(antara_qrcode PUBLIC antara::default_settings)
