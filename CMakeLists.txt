cmake_minimum_required(VERSION 3.15)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(project.metadata)
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
option(DISABLE_GEOBLOCKING "Enable to disable geoblocking (for dev purpose)" OFF)
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
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.1.3054/mm2-e423b0532-Darwin-Release.zip)
elseif (UNIX AND NOT APPLE)
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.1.3054/mm2-e423b0532-Linux-Release.zip)
else ()
    FetchContent_Declare(mm2
            URL https://github.com/KomodoPlatform/atomicDEX-API/releases/download/beta-2.1.3054/mm2-e423b0532-Windows_NT-Release.zip)
endif ()

FetchContent_Declare(qmaterial URL https://github.com/KomodoPlatform/Qaterial/archive/master.zip)

FetchContent_Declare(jl777-coins
        URL https://github.com/KomodoPlatform/coins/archive/master.zip)

FetchContent_Declare(adex-generics-coins
        URL https://github.com/KomodoPlatform/atomicdex-desktop-generics/archive/main.zip)

FetchContent_MakeAvailable(mm2 jl777-coins qmaterial adex-generics-coins)

##! Configure our needs.
if (UNIX)
    configure_file(${adex-generics-coins_SOURCE_DIR}/config/${PROJECT_VERSION}-coins.json ${CMAKE_CURRENT_SOURCE_DIR}/assets/config/${PROJECT_VERSION}-coins.json COPYONLY)
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2 ${CMAKE_CURRENT_SOURCE_DIR}/assets/tools/mm2/mm2 COPYONLY)
else ()
    configure_file(${adex-generics-coins_SOURCE_DIR}/config/${PROJECT_VERSION}-coins.json ${CMAKE_BINARY_DIR}/bin/assets/config/${PROJECT_VERSION}-coins.json COPYONLY)
    configure_file(${jl777-coins_SOURCE_DIR}/coins ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/coins COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/mm2.exe ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/mm2.exe COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/msvcp140.dll ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/msvcp140.dll COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/msvcr100.dll ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/msvcr100.dll COPYONLY)
    configure_file(${mm2_SOURCE_DIR}/vcruntime140.dll ${CMAKE_BINARY_DIR}/bin/assets/tools/mm2/vcruntime140.dll COPYONLY)
endif ()

add_subdirectory(vendor/antara-gaming_sdk/modules)

##! Osx bundle icon
set(ICON)
configure_icon_osx(data/osx/atomicdex-desktop.icns ICON atomicdex-desktop.icns)
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

set_source_files_properties(${TS_FILES} PROPERTIES OUTPUT_LOCATION "${CMAKE_SOURCE_DIR}/atomic_defi_design/assets/languages/")

qt5_create_translation(QM_FILES
        ${PROJECT_SOURCE_DIR}/atomic_defi_design/qml
        ${TS_FILES}
        OPTIONS -source-language en_US -no-obsolete)

message(STATUS "QM FILES -> ${QM_FILES}")
message(STATUS "TS FILES -> ${TS_FILES}")
##! End Lang

##! Atomic QT Shared Deps Between main executable and unit tests
if (LINUX)
    add_library(${PROJECT_NAME}_shared_deps STATIC)
else ()
    add_library(${PROJECT_NAME}_shared_deps SHARED)
endif ()
target_sources(${PROJECT_NAME}_shared_deps PRIVATE
        ##! App
        ${CMAKE_SOURCE_DIR}/src/atomicdex/app.cpp

        ##! Utilities
        ${CMAKE_SOURCE_DIR}/src/atomicdex/utilities/kill.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/utilities/cpprestsdk.utilities.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/utilities/qt.utilities.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/utilities/qt.bindings.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/utilities/security.utilities.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/utilities/global.utilities.cpp

        ##! Constants
        ${CMAKE_SOURCE_DIR}/src/atomicdex/constants/mm2.error.code.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/constants/qt.trading.enums.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/constants/qt.coins.enums.cpp

        ##! Config
        ${CMAKE_SOURCE_DIR}/src/atomicdex/config/app.cfg.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/config/coins.cfg.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/config/electrum.cfg.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/config/wallet.cfg.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/config/addressbook.cfg.cpp

        ##! Managers
        ${CMAKE_SOURCE_DIR}/src/atomicdex/managers/notification.manager.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/managers/qt.wallet.manager.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/managers/addressbook.manager.cpp

        ##! API
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/ohlc/ohlc.api.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/mm2/mm2.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/mm2/rpc.trade.preimage.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/mm2/rpc.max.taker.vol.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/mm2/rpc.enable.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/mm2/rpc.electrum.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/mm2/rpc.balance.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/mm2/generics.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/mm2/fraction.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/coinpaprika/coinpaprika.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/coingecko/coingecko.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/api/faucet/faucet.cpp

        ##! Models
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.orders.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.orders.proxy.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.candlestick.charts.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.addressbook.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.addressbook.proxy.filter.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.addressbook.contact.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.addressbook.contact.proxy.filter.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.orderbook.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.orderbook.proxy.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.portfolio.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.wallet.transactions.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.wallet.transactions.proxy.filter.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.portfolio.proxy.filter.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.global.coins.cfg.model.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/models/qt.global.coins.cfg.proxy.filter.model.cpp

        ##ToClass

        ##! Widgets
        ${CMAKE_SOURCE_DIR}/src/atomicdex/widgets/dex/qt.market.pairs.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/widgets/dex/qt.orderbook.cpp

        ##! Pages
        ${CMAKE_SOURCE_DIR}/src/atomicdex/pages/qt.trading.page.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/pages/qt.settings.page.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/pages/qt.portfolio.page.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/pages/qt.wallet.page.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/pages/qt.addressbook.page.cpp

        ##! Services
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/exporter/exporter.service.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/price/global.provider.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/price/coinpaprika/coinpaprika.provider.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/price/coingecko/coingecko.provider.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/price/oracle/band.provider.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/update/update.checker.service.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/ohlc/ohlc.provider.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/mm2/mm2.service.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/internet/internet.checker.service.cpp
        ${CMAKE_SOURCE_DIR}/src/atomicdex/services/ip/ip.checker.service.cpp

        ##! Platform
        $<$<PLATFORM_ID:Darwin>:${CMAKE_SOURCE_DIR}/src/atomicdex/platform/osx/manager.mm>
        )

target_compile_definitions(${PROJECT_NAME}_shared_deps
        PUBLIC
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
        $<$<PLATFORM_ID:Windows>:HAS_REMOTE_API>
        $<$<PLATFORM_ID:Windows>:AUTO_DOWNLOAD>
        DEX_NAME="${DEX_DISPLAY_NAME}"
        PRIVATE
        ENTT_API_EXPORT
        )


if (DISABLE_GEOBLOCKING)
    message(STATUS "Disabling Geoblocking for dev purpose")
    target_compile_definitions(${PROJECT_NAME}_shared_deps PUBLIC -DDISABLE_GEOBLOCKING)
endif ()
#target_compile_options(atomicdex-desktop_shared_deps INTERFACE -fstandalone-debug)

add_library(antara_qrcode STATIC)
target_sources(antara_qrcode PRIVATE vendor/qrcode/QrCode.cpp)
target_include_directories(antara_qrcode PUBLIC vendor/qrcode)
target_link_libraries(antara_qrcode PUBLIC antara::default_settings)

target_link_libraries(${PROJECT_NAME}_shared_deps
        PUBLIC
        Qt::Core
        Qt::Quick
        Qt::Svg
        Qt::Charts
        Qt::WebEngine
        Qt::WebEngineCore
        Qt::WebEngineWidgets
        Qt::Widgets
        antara::world
        Boost::random
        Boost::filesystem
        #absl::flat_hash_map
        komodo-sodium::sodium
        unofficial-btc::bitcoin
        reproc++
        komodo-date::date
        komodo-taskflow::taskflow
        nlohmann_json::nlohmann_json
        antara_qrcode
        #spdlog::spdlog
        #spdlog::spdlog_header_only
        cpprestsdk::cpprest
        Qaterial
        )

target_include_directories(${PROJECT_NAME}_shared_deps
        PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        PRIVATE
        $<$<PLATFORM_ID:Darwin>:${CMAKE_CURRENT_SOURCE_DIR}/src/osx>
        ${libqr_code_SOURCE_DIR}/src
        )

##! Main executable
add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${ICON}
        ${CMAKE_CURRENT_SOURCE_DIR}/data/windows/atomicdex-desktop.rc
        main.cpp
        ##! QRC
        ${CMAKE_SOURCE_DIR}/qml.qrc

        ##! Linguistic
        ${QM_FILES}
        ${TS_FILES}
        )

target_compile_definitions(${PROJECT_NAME} PRIVATE ENTT_API_IMPORT)

##! Testing executable
add_executable(${PROJECT_NAME}_tests MACOSX_BUNDLE ${ICON}
        src/atomicdex/tests/atomic.dex.tests.cpp
        src/atomicdex/tests/atomic.dex.wallet.config.tests.cpp
        src/atomicdex/tests/atomic.dex.provider.cex.prices.tests.cpp
        src/atomicdex/tests/atomic.dex.qt.utilities.tests.cpp

        ##! API
        src/atomicdex/tests/api/coingecko/coingecko.tests.cpp
        src/atomicdex/tests/api/mm2/mm2.rpc.trade.preimage.tests.cpp
        src/atomicdex/tests/api/mm2/mm2.fraction.tests.cpp

        ##! Utilities
        src/atomicdex/tests/utilities/qt.utilities.tests.cpp
        src/atomicdex/tests/utilities/global.utilities.tests.cpp

        ##! Managers
        src/atomicdex/tests/managers/addressbook.manager.tests.cpp

        ##! Models
        src/atomicdex/tests/models/qt.addressbook.contact.model.tests.cpp

        src/atomicdex/tests/atomic.dex.provider.cex.prices.api.tests.cpp)

target_link_libraries(${PROJECT_NAME}
        PUBLIC
        ${PROJECT_NAME}_shared_deps
        )

target_include_directories(${PROJECT_NAME} PUBLIC src)

target_link_libraries(${PROJECT_NAME}_tests
        PUBLIC
        ${PROJECT_NAME}_shared_deps
        doctest::doctest)

##! Setting output directory
set_target_properties(${PROJECT_NAME}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/"
        )

set_target_properties(${PROJECT_NAME}_tests
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/"
        )


target_precompile_headers(${PROJECT_NAME}_shared_deps PRIVATE src/atomicdex/pch.hpp)
#set_target_properties(atomicdex-desktop_shared_deps PROPERTIES UNITY_BUILD ON)
if (APPLE)
    set_source_files_properties(src/atomicdex/platform/osx/manager.mm PROPERTIES SKIP_PRECOMPILE_HEADERS ON)
    #set_property(SOURCE src/atomicdex/platform/osx/manager.mm PROPERTY SKIP_UNITY_BUILD_INCLUSION ON)
    #set_source_files_properties(src/atomicdex/platform/osx/manager.mm PROPERTIES SKIP_UNITY_BUILD_INCLUSION ON)
endif ()

#target_enable_tsan(atomicdex-desktop_tests)
#target_enable_asan(atomicdex-desktop)

##! Move assets
if (LINUX)
    get_target_property(exe_runtime_directory_at ${PROJECT_NAME} RUNTIME_OUTPUT_DIRECTORY)
    set(output_dir_at "${exe_runtime_directory_at}/AntaraAtomicDexAppDir")

    magic_game_app_image_generation("${CMAKE_CURRENT_SOURCE_DIR}/data/linux"
            "atomicdex-desktop.desktop"
            "atomicdex-desktop.appdata.xml"
            "atomicdex-desktop-64.png"
            atomicdex-desktop
            AntaraAtomicDexAppDir
            ${CMAKE_CURRENT_SOURCE_DIR}/assets
            )

    magic_game_app_image_generation("${CMAKE_CURRENT_SOURCE_DIR}/data/linux"
            "atomicdex-desktop.desktop"
            "atomicdex-desktop.appdata.xml"
            "atomicdex-desktop-64.png"
            atomicdex-desktop_tests
            AntaraAtomicDexTestsAppDir
            ${CMAKE_CURRENT_SOURCE_DIR}/assets
            )

    set(from_dir "${CMAKE_CURRENT_SOURCE_DIR}/data/linux")
    set(desktop_file "atomicdex-desktop.desktop")
    set(appdata_file "atomicdex-desktop.appdata.xml")
    set(app_icon "atomicdex-desktop-64.png")
    message(STATUS "${output_dir_at}")
    configure_file(${from_dir}/${desktop_file} ${output_dir_at}/usr/share/applications/${desktop_file} COPYONLY)
    configure_file(${from_dir}/${appdata_file} ${output_dir_at}/usr/share/metainfo/${appdata_file} COPYONLY)
    configure_file(${from_dir}/${app_icon} ${output_dir_at}/usr/share/icons/hicolor/64x64/apps/${app_icon} COPYONLY)
    configure_file(${from_dir}/${app_icon} ${output_dir_at}/usr/share/icons/default/64x64/apps/${app_icon} COPYONLY)
    include(data/linux/atomicdex_install.cmake)
endif ()

if (WIN32)
    set_target_properties(${PROJECT_NAME}_shared_deps PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin/)
    configure_file(wally/wally.dll ${CMAKE_BINARY_DIR}/bin/ COPYONLY)
    if (CMAKE_BUILD_TYPE MATCHES Release)
        message(STATUS "disabling console")
        target_compile_definitions(${PROJECT_NAME} PRIVATE WINDOWS_RELEASE_MAIN)
        target_compile_options(${PROJECT_NAME} PRIVATE -Wno-deprecated-declarations)
        target_link_options(${PROJECT_NAME} PUBLIC --for-linker -subsystem:windows)
    endif ()
    set(WINDEPLOYQT_PATH "")
    if (CONAN_ENABLED)
        set(WINDEPLOYQT_PATH ${CONAN_QT_ROOT}/bin/windeployqt.exe)
    else ()
        set(WINDEPLOYQT_PATH $ENV{QT_INSTALL_CMAKE_PATH}/bin/windeployqt.exe)
    endif ()

    if (EXISTS ${WINDEPLOYQT_PATH})
        message(STATUS "windeployqt path is -> ${WINDEPLOYQT_PATH}")
    else ()
        message(FATAL_ERROR "Didn't find windeployqt ${WINDEPLOYQT_PATH}")
    endif ()
    add_custom_command(TARGET ${PROJECT_NAME} PRE_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/windows_misc $<TARGET_FILE_DIR:${PROJECT_NAME}>)
    message(STATUS "${WINDEPLOYQT_PATH} ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.exe ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}_shared_deps.dll --qmldir ${CMAKE_SOURCE_DIR}/atomic_defi_design/qml")
    add_custom_command(TARGET ${PROJECT_NAME}
            POST_BUILD
            COMMAND ${WINDEPLOYQT_PATH} ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.exe ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}_shared_deps.dll --qmldir ${CMAKE_SOURCE_DIR}/atomic_defi_design/qml
            )
    include(data/windows/atomicdex_install.cmake)
endif ()

if (APPLE)
    file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}.app/Contents/Resources)
    file(COPY assets DESTINATION ${CMAKE_BINARY_DIR}/bin/${PROJECT_NAME}_tests.app/Contents/Resources)
    include(data/osx/atomicdex_install.cmake)
endif ()

if (WITH_HOTRELOAD)
    add_compile_definitions(ATOMICDEX_HOT_RELOAD)
    message(STATUS "Hot reload enabled")
    include(hot_reload/cmake/Configuration.cmake)
    include(hot_reload/cmake/FetchDependencies.cmake)
    set(QATERIALHOTRELOAD_LIB QaterialHotReload)
    set(QATERIALHOTRELOAD_SRC_DIR ${CMAKE_SOURCE_DIR}/hot_reload/src/Qaterial/HotReload)
    add_subdirectory(hot_reload/qml/Qaterial/HotReload)


    add_library(${QATERIALHOTRELOAD_LIB} STATIC
            ${QATERIALHOTRELOAD_SRC_DIR}/HotReload.hpp
            ${QATERIALHOTRELOAD_SRC_DIR}/HotReload.cpp
            ${QATERIALHOTRELOAD_QML_RES}
            )
    add_library(Qaterial::HotReload ALIAS ${QATERIALHOTRELOAD_LIB})

    target_link_libraries(${QATERIALHOTRELOAD_LIB} PUBLIC
            Qaterial
            SortFilterProxyModel
            ${PROJECT_NAME}_shared_deps
            )
    target_link_libraries(${QATERIALHOTRELOAD_LIB} PRIVATE
            Qaterial::HotReload::Ui
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

    target_link_libraries(${PROJECT_NAME} PRIVATE Qaterial::HotReload)
endif ()
