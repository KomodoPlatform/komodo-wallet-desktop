set build_folder=build-Release\bin
set root_folder=installer
set installer_target=%root_folder%\AtomicDEX-Pro-Installer.exe
set installer_folder=%root_folder%\windows
set installer_data=%installer_folder%\packages\com.komodoplatform.atomicdexpro\data
set config_file=%installer_folder%\config\config.xml
set packages_folder=%installer_folder%\packages
set icon_file=%root_folder%\app_icon.ico
set manifest_file=%installer_folder%\atomic_qt.exe.manifest

REM Delete old data
@RD /S /Q "%installer_data%"

REM Copy new data
echo D | xcopy "%build_folder%" "%installer_data%" /E

REM Copy icon
xcopy "%icon_file%" "%installer_data%"

REM Copy exe manifest
xcopy "%manifest_file%" "%installer_data%"

call %QT_IFW_PATH%\bin\binarycreator.exe -c "%config_file%" -p "%packages_folder%" "%installer_target%"