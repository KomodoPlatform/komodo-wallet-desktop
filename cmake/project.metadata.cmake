# Default project values

set(DEX_PROJECT_NAME "shibaDEX")
set(DEX_DISPLAY_NAME "shibaDEX Desktop")
set(DEX_MAINTENANCE_TOOL_NAME "shibaDEX Maintenance Tool")
set(DEX_COMPANY "CZ Web Service S.A")
set(DEX_WEBSITE "https://shibadex.io/")
set(DEX_API "mm2-shibadex")
set(DEX_RPCPORT 7883)
set(DEX_RPC "http://127.0.0.1:7883")
set(DEX_SUPPORT_PAGE "https://support.komodoplatform.com/support/home")
set(DEX_DISCORD "https://komodoplatform.com/discord")
set(DEX_TWITTER "https://twitter.com/shibadex")
set(DEX_PRIMARY_COIN "KMD")                                                         ## Main coin of the DEX, will be enabled by default and will be the default left ticker for trading
set(DEX_SECOND_PRIMARY_COIN "LTC")                                                  ## Second main coin of the DEX, will be enabled by default and will be the default right ticker for trading
option(DISABLE_GEOBLOCKING "Enable to disable geoblocking (for dev purpose)" ON)
set(DEX_REPOSITORY_OWNER "KomodoPlatform")
set(DEX_REPOSITORY_NAME "atomicDEX-Desktop")
set(DEX_CHECKSUM_API_URL "https://komodo.live/static/checksum.json")
if (APPLE)
    set(DEX_APPDATA_FOLDER "shibadex")
else ()
    set(DEX_APPDATA_FOLDER "shibadex")
endif ()
message(STATUS "APPDATA folder is ${DEX_APPDATA_FOLDER}")

if (UNIX AND NOT APPLE)
    set(DEX_LINUX_APP_ID "dex.desktop")
endif ()

# Erases default project values with environment variables if they exist.
if (DEFINED ENV{DEX_API})
    set(DEX_API $ENV{DEX_API})
endif ()
if (DEFINED ENV{DEX_RPCPORT})
    set(DEX_RPCPORT $ENV{DEX_RPCPORT})
endif ()
if (DEFINED ENV{DEX_RPC})
    set(DEX_RPC $ENV{DEX_RPC})
endif ()
if (DEFINED ENV{DEX_PROJECT_NAME})
    set(DEX_PROJECT_NAME $ENV{DEX_PROJECT_NAME})
endif ()
if (DEFINED ENV{DEX_DISPLAY_NAME})
    set(DEX_DISPLAY_NAME $ENV{DEX_DISPLAY_NAME})
endif ()
if (DEFINED ENV{DEX_COMPANY})
    set(DEX_COMPANY $ENV{DEX_COMPANY})
endif ()
if (DEFINED ENV{DEX_WEBSITE})
    set(DEX_WEBSITE $ENV{DEX_WEBSITE})
endif ()

# Shows project metadata
message(STATUS "Project Metadata: ${DEX_PROJECT_NAME}.${DEX_DISPLAY_NAME}.${DEX_COMPANY}.${DEX_WEBSITE}")

# Generates files which need to be configured with custom variables from env/CMake.
macro(generate_dex_project_metafiles)
    # Configures installers
    if (APPLE)
        generate_macos_metafiles()
    elseif (WIN32)
        generate_windows_metafiles()
    else ()
        generate_linux_metafiles()
    endif ()

    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo-big.png
            ${CMAKE_CURRENT_LIST_DIR}/atomic_defi_design/assets/images/dex-logo-big.png COPYONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo.png
            ${CMAKE_CURRENT_LIST_DIR}/atomic_defi_design/assets/images/logo/dex-logo.png COPYONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-tray-icon.png
            ${CMAKE_CURRENT_LIST_DIR}/atomic_defi_design/assets/images/dex-tray-icon.png COPYONLY)
endmacro()

macro(generate_macos_metafiles)
    set(DEX_APP_DIR "@ApplicationsDir@")
    set(DEX_TARGET_DIR "@TargetDir@")
    set(DEX_RUN_CMD "@TargetDir@/${DEX_PROJECT_NAME}.app/Contents/MacOS/${DEX_PROJECT_NAME}")

    configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/config/config.xml.in
            ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/config/config.xml)
    configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/packages/com.komodoplatform.atomicdex/meta/package.xml.in
            ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/packages/com.komodoplatform.atomicdex/meta/package.xml)
    configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/packages/com.komodoplatform.atomicdex/meta/installscript.qs.in
            ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/packages/com.komodoplatform.atomicdex/meta/installscript.qs)

    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo.icns ${CMAKE_CURRENT_LIST_DIR}/cmake/install/macos/dex-logo.icns COPYONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo.icns ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/config/install_icon.icns COPYONLY)               # Configures MacOS logo for the installer
    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo.png ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/config/install_icon.png COPYONLY)
endmacro()

macro(generate_windows_metafiles)
    set(DEX_TARGET_DIR "@TargetDir@")
    set(DEX_START_MENU_DIR "@StartMenuDir@")
    set(DEX_DESKTOP_DIR "@DesktopDir@")
    set(DEX_ICON_DIR "@TargetDir@/${DEX_PROJECT_NAME}.ico")
    set(DEX_MANIFEST_DESCRIPTION "${DEX_DISPLAY_NAME}, a desktop wallet application")
    set(DEX_INSTALL_TARGET_DIR_WIN64 "@ApplicationsDirX64@")

    configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/config/config.xml.in
            ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/config/config.xml)
    configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/meta/package.xml.in
            ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/meta/package.xml)
    configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/meta/installscript.qs.in
            ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/meta/installscript.qs)
    configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/dex.exe.manifest.in
            ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/data/${DEX_PROJECT_NAME}.exe.manifest)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo.ico
            ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/data/${DEX_PROJECT_NAME}.ico
            COPYONLY)

    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo.ico ${CMAKE_CURRENT_LIST_DIR}/cmake/install/windows/dex-logo.ico COPYONLY)
    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo.ico ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/config/install_icon.ico COPYONLY)             # Configures Windows logo for the installer
    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo.png ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/config/install_icon.png COPYONLY)
endmacro()

macro(generate_linux_metafiles)
    configure_file(${CMAKE_SOURCE_DIR}/cmake/install/linux/dex.appdata.xml.in
            ${CMAKE_SOURCE_DIR}/cmake/install/linux/dex.appdata.xml)
    configure_file(${CMAKE_SOURCE_DIR}/cmake/install/linux/dex.desktop.in
            ${CMAKE_SOURCE_DIR}/cmake/install/linux/dex.desktop)

    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo-64.png ${CMAKE_CURRENT_LIST_DIR}/cmake/install/linux/dex-logo-64.png COPYONLY)                                  # Configures x64 Linux logo
    configure_file(${CMAKE_CURRENT_LIST_DIR}/assets/logo/dex-logo.png ${CMAKE_CURRENT_LIST_DIR}/cmake/install/linux/dex-logo.png COPYONLY)
endmacro()
