set(DEX_PROJECT_NAME "atomicdex-desktop")
set(DEX_DISPLAY_NAME "AtomicDEX Desktop")
set(DEX_COMPANY "KomodoPlatform")
set(DEX_WEBSITE "https://atomicdex.io/")

# Do not touch!
set(DEX_TARGET_DIR "@ApplicationsDir@/${DEX_DISPLAY_NAME}")
set(DEX_TARGET_DIR_WIN64 "@ApplicationsDirX64@/${DEX_DISPLAY_NAME}")
set(DEX_RUN_CMD "@TargetDir@/${DEX_PROJECT_NAME}.app/Contents/MacOS/${DEX_PROJECT_NAME}")
set(DEX_RUN_CMD_WIN64 "@TargetDir@/${DEX_PROJECT_NAME}.exe")

# Configures installers
configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/config/config.xml.in ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/config/config.xml)
configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/packages/com.komodoplatform.atomicdex/meta/package.xml.in ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/osx/packages/com.komodoplatform.atomicdex/meta/package.xml)
configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/config/config.xml.in ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/config/config.xml)
configure_file(${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/meta/package.xml.in ${CMAKE_SOURCE_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/meta/package.xml)