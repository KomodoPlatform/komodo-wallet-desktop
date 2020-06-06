cmake_minimum_required(VERSION 3.5)

project(atomic_qt LANGUAGES CXX)


set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


if (WIN32)
    find_package(ZLIB)
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Override option" FORCE)
endif ()

##! Antara
##! We include the module from CMake for fetching dependencies
include(FetchContent)

##! We declare information about the dependance that we want to fetch.
FetchContent_Declare(
        antara-gaming-sdk
        URL https://github.com/KomodoPlatform/antara-gaming-sdk/archive/master.zip

)

set(ANTARA_USE_VCPKG ON)
set(ENABLE_BLOCKCHAIN_MODULES ON)

FetchContent_GetProperties(antara-gaming-sdk)
if (NOT antara-gaming-sdk_POPULATED)
    FetchContent_Populate(antara-gaming-sdk)
    add_subdirectory(${antara-gaming-sdk_SOURCE_DIR} ${antara-gaming-sdk_BINARY_DIR} EXCLUDE_FROM_ALL)
endif ()

if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    set(LINUX TRUE)
endif()

if (UNIX AND NOT APPLE)
   set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++abi")
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
endif()

##! We fetch our dependence
if (APPLE)
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.0.2002/mm2-3a9680fa4-Darwin-Release.zip)
elseif (UNIX AND NOT APPLE)
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.0.2002/mm2-3a9680fa4-Linux-Release.zip)
else ()
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.0.2002/mm2-3a9680fa4-Windows_NT-Release.zip)
endif ()

FetchContent_Declare(jl777-coins
        URL https://github.com/KomodoPlatform/coins/archive/master.zip)

FetchContent_MakeAvailable(mm2 jl777-coins)

##! Configure our needs.
if (UNIX)
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2 ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/mm2 COPYONLY)
else ()
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2.exe ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/mm2.exe COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/msvcp140.dll ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/msvcp140.dll COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/msvcr100.dll ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/msvcr100.dll COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/vcruntime140.dll ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/vcruntime140.dll COPYONLY)
endif ()

FetchContent_Declare(libqr_code
        URL https://github.com/KomodoPlatform/qzxing/archive/master.zip)

FetchContent_GetProperties(libqr_code)
if (NOT libqr_code_POPULATED)
    FetchContent_Populate(libqr_code)
    add_subdirectory(${libqr_code_SOURCE_DIR}/src ${libqr_code_BINARY_DIR} EXCLUDE_FROM_ALL)
endif ()

##! Calling this macros provided by the sdk will if you are on Apple init the environment for this OS (std::filesystem).
init_antara_env()

##! Get basis assets (default fonts, etc)
get_resources_basics_assets(${CMAKE_CURRENT_SOURCE_DIR})

##! Osx bundle icon
set(ICON)
configure_icon_osx(data/osx/kmd_logo.icns ICON kmd_logo.icns)
##! End antara

find_package(folly CONFIG REQUIRED)
find_package(Boost REQUIRED COMPONENTS filesystem random)
find_package(Qt5 COMPONENTS Core Quick LinguistTools Svg Charts REQUIRED)
find_package(unofficial-sodium CONFIG REQUIRED)
find_library(unofficial-bitcoin-external bitcoin)
find_path(unofficial-btc-headers bitcoin/bitcoin.hpp)
message(STATUS "Found libbtc -> ${unofficial-bitcoin-external} ${unofficial-btc-headers}")
add_library(unofficial-bitcoin INTERFACE)
if (APPLE)
    target_link_libraries(unofficial-bitcoin INTERFACE ${unofficial-bitcoin-external})
    target_include_directories(unofficial-bitcoin INTERFACE ${unofficial-btc-headers})
elseif(WIN32)
    target_link_directories(unofficial-bitcoin INTERFACE wally)
    target_link_libraries(unofficial-bitcoin INTERFACE wally)
    target_include_directories(unofficial-bitcoin INTERFACE wally)
else ()
    find_library(unofficial-secp secp256k1)
    find_library(unofficial-wally wallycore)
    find_path(unofficial-wally-headers wally_core.h)
    target_link_libraries(unofficial-bitcoin INTERFACE ${unofficial-wally} ${unofficial-secp})
    target_include_directories(unofficial-bitcoin INTERFACE ${unofficial-wally-headers})
endif()
add_library(unofficial-btc::bitcoin ALIAS unofficial-bitcoin)

set(TS_FILES
        ${CMAKE_SOURCE_DIR}/atomic_qt_design/assets/languages/atomic_qt_en.ts
        ${CMAKE_SOURCE_DIR}/atomic_qt_design/assets/languages/atomic_qt_fr.ts
        ${CMAKE_SOURCE_DIR}/atomic_qt_design/assets/languages/atomic_qt_tr.ts)
set_source_files_properties(${TS_FILES} PROPERTIES OUTPUT_LOCATION "${CMAKE_SOURCE_DIR}/atomic_qt_design/assets/languages/")
qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR}/atomic_qt_design/qml ${TS_FILES})
qt5_add_translation(qmFiles ${TS_FILES})
message(STATUS "${QM_FILES}")
message(STATUS "${TS_FILES}")

if (ANDROID)
    add_library(atomic_qt SHARED
            main.cpp
            qml.qrc
            ${TS_FILES}
            )
else ()
    add_executable(atomic_qt MACOSX_BUNDLE ${ICON}
            main.cpp
            src/atomic.dex.kill.cpp
            src/atomic.dex.app.cpp
            src/atomic.dex.cfg.cpp
            src/atomic.dex.mm2.cpp
            src/atomic.dex.coins.config.cpp
            src/atomic.dex.mm2.api.cpp
            src/atomic.dex.mm2.error.code.cpp
            src/atomic.dex.provider.coinpaprika.api.cpp
            src/atomic.dex.qt.bindings.cpp
            src/atomic.dex.provider.coinpaprika.cpp
            src/atomic.dex.qt.current.coin.infos.cpp
            src/atomic.dex.security.cpp
            $<$<PLATFORM_ID:Darwin>:src/osx/atomic.dex.osx.manager.mm>
            qml.qrc
            ${qmFiles}
            )
endif ()

add_compile_definitions(LOGURU_WITH_FILEABS=1)
target_compile_definitions(atomic_qt
        PRIVATE
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_include_directories(atomic_qt PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
        $<$<PLATFORM_ID:Darwin>:${CMAKE_CURRENT_SOURCE_DIR}/src/osx>
        ${libqr_code_SOURCE_DIR}/src)
target_link_libraries(atomic_qt
        PRIVATE
        Qt5::Core
        Qt5::Quick
        Qt5::Svg
        Qt5::Charts
        qzxing
        antara::world
        Boost::filesystem
        $<$<PLATFORM_ID:Linux>:Boost::random>
        unofficial-sodium::sodium
        unofficial-btc::bitcoin
        reproc++
        antara::http_client
        Folly::folly
        Folly::folly_deps
        $<$<PLATFORM_ID:Darwin>:/usr/local/lib/libcurl.a>
        )
#target_enable_asan(atomic_qt)

##! Setting output directory
set_target_properties(${PROJECT_NAME}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/"
        )

if (LINUX)
    get_target_property(exe_runtime_directory_at ${PROJECT_NAME} RUNTIME_OUTPUT_DIRECTORY)
    set(output_dir_at "${exe_runtime_directory_at}/AntaraAtomicDexAppDir")

    magic_game_app_image_generation("${CMAKE_CURRENT_SOURCE_DIR}/data/linux"
            "atomic_qt.desktop"
            "atomic_qt.appdata.xml"
            "komodo_icon.png"
            atomic_qt
            AntaraAtomicDexAppDir
            ${CMAKE_CURRENT_SOURCE_DIR}/assets
            )

    set(from_dir "${CMAKE_CURRENT_SOURCE_DIR}/data/linux")
    set(desktop_file "atomic_qt.desktop")
    set(appdata_file "atomic_qt.appdata.xml")
    set(app_icon "komodo_icon.png")
    message(STATUS "${output_dir_at}")
    configure_file(${from_dir}/${desktop_file} ${output_dir_at}/usr/share/applications/${desktop_file} COPYONLY)
    configure_file(${from_dir}/${appdata_file} ${output_dir_at}/usr/share/metainfo/${appdata_file} COPYONLY)
    configure_file(${from_dir}/${app_icon} ${output_dir_at}/usr/share/icons/hicolor/128x128/apps/${app_icon} COPYONLY)
endif()

##! Move assets
if (WIN32)
    file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin/)
    configure_file(wally/wally.dll ${CMAKE_BINARY_DIR}/bin/ COPYONLY)
    set_target_properties(Folly::folly PROPERTIES INTERFACE_COMPILE_OPTIONS "")
    if(CMAKE_BUILD_TYPE MATCHES Release)
      message(STATUS "disabling console")
      target_compile_definitions(atomic_qt PRIVATE WINDOWS_RELEASE_MAIN)
      target_link_options(atomic_qt PUBLIC --for-linker -subsystem:windows)
    endif()
endif ()

if (APPLE)
    file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.app/Contents/Resources)
    include(data/osx/atomicdex_install.cmake)
endif ()
