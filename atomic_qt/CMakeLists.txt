cmake_minimum_required(VERSION 3.5)

project(atomic_qt LANGUAGES CXX)


set(CMAKE_INCLUDE_CURRENT_DIR ON)

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

##! We fetch our dependence
if (APPLE)
    FetchContent_Declare(mm2
            URL http://195.201.0.6/mm2/mm2-latest-Darwin.zip)
elseif (UNIX AND NOT APPLE)
    FetchContent_Declare(mm2
            URL http://195.201.0.6/mm2/mm2-latest-Linux.zip)
else ()
    FetchContent_Declare(mm2
            URL http://195.201.0.6/mm2/mm2-latest-Windows_NT.zip)
endif ()

FetchContent_Declare(jl777-coins
        URL https://github.com/jl777/coins/archive/master.zip)

FetchContent_MakeAvailable(mm2 jl777-coins)

##! Configure our needs.
if (UNIX)
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2 ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/mm2 COPYONLY)
else ()
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2.exe ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/mm2.exe COPYONLY)
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
find_package(Boost REQUIRED)
find_package(Qt5 COMPONENTS Core Quick LinguistTools REQUIRED)
find_package(unofficial-sodium CONFIG REQUIRED)
find_library(unofficial-bitcoin-external bitcoin)
find_path(unofficial-btc-headers bitcoin/bitcoin.hpp)
message(STATUS "Found libbtc -> ${unofficial-bitcoin-external} ${unofficial-btc-headers}")
add_library(unofficial-bitcoin INTERFACE)
if (APPLE)
    target_link_libraries(unofficial-bitcoin INTERFACE ${unofficial-bitcoin-external})
    target_include_directories(unofficial-bitcoin INTERFACE ${unofficial-btc-headers})
endif()
add_library(unofficial-btc::bitcoin ALIAS unofficial-bitcoin)

set(TS_FILES atomic_qt_en_US.ts)

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
            src/atomic.dex.mm2.cpp
            src/atomic.dex.coins.config.cpp
            src/atomic.dex.mm2.api.cpp
            src/atomic.dex.mm2.error.code.cpp
            src/atomic.dex.provider.coinpaprika.api.cpp
            src/atomic.dex.qt.bindings.cpp
            src/atomic.dex.provider.coinpaprika.cpp
            src/atomic.dex.security.cpp
            $<$<PLATFORM_ID:Darwin>:src/osx/atomic.dex.osx.manager.mm>
            qml.qrc
            ${TS_FILES}
            )
endif ()


target_compile_definitions(atomic_qt
        PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_include_directories(atomic_qt PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src  $<$<PLATFORM_ID:Darwin>:${CMAKE_CURRENT_SOURCE_DIR}/src/osx>)
target_link_libraries(atomic_qt
        PRIVATE
        Qt5::Core
        Qt5::Quick
        antara::world
        unofficial-sodium::sodium
        unofficial-btc::bitcoin
        reproc++
        antara::http_client
        Folly::folly
        Folly::folly_deps
        )

qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})

##! Setting output directory
set_target_properties(${PROJECT_NAME}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/"
        )

magic_game_app_image_generation("${CMAKE_CURRENT_SOURCE_DIR}/data/linux"
        "org.antara.gaming.atomicdex.desktop"
        "org.antara.gaming.atomicdex.appdata.xml"
        "komodo_icon.png"
        atomic_qt
        AntaraAtomicDexAppDir
        ${CMAKE_CURRENT_SOURCE_DIR}/assets
        )

##! Move assets
if (WIN32)
    file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin/)
    set_target_properties(Folly::folly PROPERTIES INTERFACE_COMPILE_OPTIONS "")
endif ()

if (APPLE)
    file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.app/Contents/Resources)
    include(data/osx/atomicdex_install.cmake)
endif ()
