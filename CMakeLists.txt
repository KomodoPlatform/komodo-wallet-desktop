cmake_minimum_required(VERSION 3.15)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(project.metadata)           ##> generate_dex_project_metafiles()
generate_dex_project_metafiles()

include(build_type)
include(compiler_prerequisites)
include(vcpkg_prerequisites)
include(qt_prerequisites)
include(cfg_hash)

project(${DEX_PROJECT_NAME} LANGUAGES CXX VERSION 0.4.0)
message(STATUS "${PROJECT_NAME} is version ${PROJECT_VERSION}")

include(cmake_default_options)
include(ipo_prerequisites)

##! Options
option(PREFER_BOOST_FILESYSTEM "Enable to use boost filesystem instead of std::filesystem" OFF)
option(WITH_HOTRELOAD "Enable to use qml Hot reload" OFF)

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
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.1.3162/mm2-54eb039bf-Darwin-Release.zip)
elseif (UNIX AND NOT APPLE)
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.1.3162/mm2-54eb039bf-Linux-Release.zip)
else ()
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.1.3162/mm2-54eb039bf-Windows_NT-Release.zip)
endif ()

FetchContent_Declare(qmaterial URL https://github.com/KomodoPlatform/Qaterial/archive/master.zip)

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

##Lang
set_directory_properties(PROPERTIES CLEAN_NO_CUSTOM TRUE)

set(TS_FILES
        ${CMAKE_SOURCE_DIR}/atomic_defi_design/assets/languages/atomic_defi_en.ts
        ${CMAKE_SOURCE_DIR}/atomic_defi_design/assets/languages/atomic_defi_fr.ts
        ${CMAKE_SOURCE_DIR}/atomic_defi_design/assets/languages/atomic_defi_tr.ts
        ${CMAKE_SOURCE_DIR}/atomic_defi_design/assets/languages/atomic_defi_ru.ts)

set_source_files_properties(${TS_FILES} PROPERTIES OUTPUT_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/atomic_defi_design/assets/languages//atomic_defi_design/assets/languages)

qt5_create_translation(QM_FILES
        ${PROJECT_SOURCE_DIR}/atomic_defi_design/qml
        ${TS_FILES}
        OPTIONS -source-language en_US -no-obsolete)

message(STATUS "QM FILES -> ${QM_FILES}")
message(STATUS "TS FILES -> ${TS_FILES}")
##! End Lang

add_subdirectory(src)

add_library(antara_qrcode STATIC)
target_sources(antara_qrcode PRIVATE vendor/qrcode/QrCode.cpp)
target_include_directories(antara_qrcode PUBLIC vendor/qrcode)
target_link_libraries(antara_qrcode PUBLIC antara::default_settings)