if (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "Prevented in-tree build. Please create a build directory outside of the source code and call cmake from there")
endif ()

##! Minimum version of the CMake.
cmake_minimum_required(VERSION 3.14)

##! C++ Standard needed by the SDK is 17
set(CMAKE_CXX_STANDARD 17)

option(USE_UNITY_BUILD OFF)
option(USE_PCH_HEADERS OFF)

if (USE_UNITY_BUILD)
    set(CMAKE_EXPORT_COMPILE_COMMANDS OFF)
else ()
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endif ()

##! Our Project title, here atomic-dex-desktop.
project(atomic-dex-desktop DESCRIPTION "An awesome atomic-dex-desktop" LANGUAGES CXX VERSION 1.0.0)

if (WIN32)
    find_package(ZLIB)
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Override option" FORCE)
endif ()

##! The SDK need's clang as main compiler.
if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "AppleClang")
        if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
            message(FATAL_ERROR "Only Clang is supported (minimum LLVM 8.0)")
        endif ()
    endif ()
endif ()

##! We will let know the SDK if our on Linux
if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    set(LINUX TRUE)
endif ()

##! Options
option(ENABLE_CODE_RELOAD_UNIX "Enable hot-code reloading on unix" OFF)
option(ENABLE_CODE_RELOAD_WINDOWS "Enable hot-code reloading on windows" OFF)
option(USE_V2_UI "Enable V2 UI" OFF)

##! We include the module from CMake for fetching dependencies
include(FetchContent)

##! We declare information about the dependance that we want to fetch.
FetchContent_Declare(
        antara-gaming-sdk
        URL https://github.com/KomodoPlatform/antara-gaming-sdk/archive/master.zip

)

if (UNIX)
    FetchContent_Declare(
            jetlive
            URL https://github.com/ddovod/jet-live/archive/master.zip
    )
endif ()

FetchContent_Declare(
        iconfontcppheaders
        URL https://github.com/juliettef/IconFontCppHeaders/archive/master.zip
)

##! We set extras modules from the SDK that we want to use, here we will use the SDL module.
set(USE_SDL_ANTARA_WRAPPER ON)
set(USE_IMGUI_ANTARA_WRAPPER ON)
set(ANTARA_USE_VCPKG ON)
set(ENABLE_BLOCKCHAIN_MODULES ON)

##! We fetch our dependence
if (APPLE)
    FetchContent_Declare(mm2
            URL http://195.201.0.6/mm2/mm2-latest-Darwin.zip)
elseif (LINUX)
    FetchContent_Declare(mm2
            URL http://195.201.0.6/mm2/mm2-latest-Linux.zip)
else ()
    FetchContent_Declare(mm2
            URL http://195.201.0.6/mm2/mm2-latest-Windows_NT.zip)
endif ()

FetchContent_Declare(jl777-coins
        URL https://github.com/jl777/coins/archive/master.zip)

FetchContent_MakeAvailable(mm2 jl777-coins iconfontcppheaders)
##! Configure our needs.
if (UNIX)
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2 ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/mm2 COPYONLY)
else ()
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2.exe ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/mm2.exe COPYONLY)
endif ()

#FetchContent_MakeAvailable(antara-gaming-sdk)
FetchContent_GetProperties(antara-gaming-sdk)
if (NOT antara-gaming-sdk_POPULATED)
    FetchContent_Populate(antara-gaming-sdk)
    add_subdirectory(${antara-gaming-sdk_SOURCE_DIR} ${antara-gaming-sdk_BINARY_DIR} EXCLUDE_FROM_ALL)
endif ()

##! Calling this macros provided by the sdk will if you are on Apple init the environment for this OS (std::filesystem).
init_antara_env()

##! Get basis assets (default fonts, etc)
get_resources_basics_assets(${CMAKE_CURRENT_SOURCE_DIR})

##! Osx bundle icon
set(ICON src/atomic.dex.gui.v2.credentials.view.cpp src/atomic.dex.gui.v2.waiting.view.cpp)
configure_icon_osx(data/osx/kmd_logo.icns ICON kmd_logo.icns)

##! We create the executable with the project name
add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${ICON}
        atomic.dex.desktop.cpp
        src/atomic.dex.app.cpp
        src/atomic.dex.gui.cpp
        src/atomic.dex.gui.v2.cpp
        src/atomic.dex.gui.v2.credentials.view.cpp
        src/atomic.dex.gui.v2.waiting.view.cpp
        src/atomic.dex.mm2.cpp
        src/atomic.dex.mm2.api.cpp
        src/atomic.dex.gui.style.cpp
        src/atomic.dex.gui.widgets.cpp
        src/atomic.dex.coins.config.cpp
        src/atomic.dex.mm2.error.code.cpp
        src/atomic.dex.provider.coinpaprika.cpp
        src/atomic.dex.provider.coinpaprika.api.cpp
        src/atomic.dex.kill.cpp
        src/atomic.dex.security.cpp)


if (USE_V2_UI)
    target_compile_definitions(${PROJECT_NAME} PUBLIC -DATOMICDEX_V2_UI)
endif()

if (UNIX AND ENABLE_CODE_RELOAD_UNIX)
    target_compile_definitions(${PROJECT_NAME} PUBLIC -DENABLE_CODE_RELOAD_UNIX)
    FetchContent_GetProperties(jetlive)
    if (NOT jetlive_POPULATED)
        FetchContent_Populate(jetlive)
        include(${jetlive_SOURCE_DIR}/cmake/jet_live_setup.cmake) # setup needed compiler and linker flags, include this file in your root CMakeLists.txt
        set(JET_LIVE_BUILD_EXAMPLE OFF CACHE BOOL "Override option" FORCE)
        set(JET_LIVE_SHARED ON CACHE BOOL "Override option" FORCE)
        add_subdirectory(${jetlive_SOURCE_DIR} ${jetlive_BINARY_DIR} EXCLUDE_FROM_ALL)
        target_link_libraries(${PROJECT_NAME} PUBLIC jet-live)
    endif ()
endif ()

target_include_directories(${PROJECT_NAME} PUBLIC src ${iconfontcppheaders_SOURCE_DIR})

##! Setting output directory
set_target_properties(${PROJECT_NAME}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/"
        )

magic_game_app_image_generation("${CMAKE_CURRENT_SOURCE_DIR}/data/linux"
        "org.antara.gaming.atomicdex.desktop"
        "org.antara.gaming.atomicdex.appdata.xml"
        "komodo_icon.png"
        atomic-dex-desktop
        AntaraAtomicDexAppDir
        ${CMAKE_CURRENT_SOURCE_DIR}/assets
        )

##! We link the SDK modules that we want to use to our executable
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Override option" FORCE)

find_package(folly CONFIG REQUIRED)
find_package(Boost REQUIRED)
find_package(date CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(unofficial-sodium CONFIG REQUIRED)
find_library(unofficial-bitcoin-external bitcoin)
find_path(unofficial-btc-headers bitcoin/bitcoin.hpp)
message(STATUS "Found libbtc -> ${unofficial-bitcoin-external} ${unofficial-btc-headers}")
add_library(unofficial-bitcoin INTERFACE)
target_link_libraries(unofficial-bitcoin INTERFACE ${unofficial-bitcoin-external})
target_include_directories(unofficial-bitcoin INTERFACE ${unofficial-btc-headers})
add_library(unofficial-btc::bitcoin ALIAS unofficial-bitcoin)
target_link_libraries(${PROJECT_NAME} PUBLIC
        antara::world
        antara::event
        reproc++
        joboccara::pipes
        nlohmann_json::nlohmann_json
        antara::http_client
        Folly::folly
        Folly::folly_deps
        Boost::headers
        date::date
        date::tz
        antara::sdl
        unofficial-btc::bitcoin
        unofficial-sodium::sodium)

##! Move assets
if (WIN32)
    file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin/)
endif ()

if (APPLE)
    file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.app/Contents/Resources)
    include(data/osx/atomicdex_install.cmake)
endif ()

#target_enable_tsan(${PROJECT_NAME})
target_enable_ubsan(${PROJECT_NAME})
if (CMAKE_VERSION VERSION_GREATER 3.15)
    set(IMGUI_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/_deps/imgui-src/examples)
    if (USE_UNITY_BUILD)
        set_target_properties(${PROJECT_NAME} PROPERTIES UNITY_BUILD ON)
        set_property(SOURCE ${IMGUI_SOURCE_DIR}/imgui_impl_osx.mm PROPERTY SKIP_UNITY_BUILD_INCLUSION ON)
        set_source_files_properties(${IMGUI_SOURCE_DIR}/imgui_impl_osx.mm PROPERTIES SKIP_UNITY_BUILD_INCLUSION ON)
    endif ()
    if (USE_PCH_HEADERS)
        set_source_files_properties(${IMGUI_SOURCE_DIR}/imgui_impl_osx.mm PROPERTIES SKIP_PRECOMPILE_HEADERS ON)
        target_precompile_headers(${PROJECT_NAME} PRIVATE src/atomic.dex.pch.hpp)
    endif ()
endif ()

if (WIN32)
    init_windows_env()
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC" AND ENABLE_CODE_RELOAD_WINDOWS)
        target_compile_definitions(${PROJECT_NAME} PUBLIC -DENABLE_CODE_RELOAD_WINDOWS)
        #target_compile_options(${PROJECT_NAME} PUBLIC /ho)
        target_link_options(${PROJECT_NAME} PUBLIC /DEBUG:FULL)
        target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/API)
    endif ()
    get_target_property(_target_cxx_options ${PROJECT_NAME} COMPILE_OPTIONS)
    get_target_property(_target_cxx_flags ${PROJECT_NAME} COMPILE_FLAGS)
    message(STATUS "target flag -> ${_target_cxx_flags}")
    message(STATUS "target options -> ${_target_cxx_options}")
    message(STATUS "global flags -> ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG} ${CMAKE_CXX_FLAGS_RELEASE}")
    get_target_property(_opt_old Folly::folly INTERFACE_COMPILE_OPTIONS)
    message(STATUS "INTERFACE OPTIONS -> ${_opt_old}")
    ## tmp replace all fcking folly flags
    if (NOT ClangCL AND NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        set_target_properties(Folly::folly PROPERTIES INTERFACE_COMPILE_OPTIONS "")
        message(STATUS "Override some flags")
        target_compile_options(${PROJECT_NAME} PUBLIC -Wno-ignored-attributes -Wno-deprecated-declarations -Wno-sign-compare)
    endif ()
endif ()