set build_folder=build-Release\bin
set root_folder=installer
set icon_file=app_icon.ico
set installer_target=%root_folder%\AtomicDEX-Pro-Installer.exe
set installer_folder=%root_folder%\AtomicDEX Pro Installer
set installer_data=%installer_folder%\packages\com.komodoplatform.atomicdexpro\data
set config_file=%installer_folder%\config\config.xml
set packages_folder=%installer_folder%\packages

REM Delete old data
@RD /S /Q "%installer_data%"

REM Copy new data
echo D | xcopy "%build_folder%" "%installer_data%" /E

REM Copy icon
xcopy "%root_folder%\%icon_file%" "%installer_data%"

call %QT_IFW_PATH%\bin\binarycreator.exe -c "%config_file%" -p "%packages_folder%" "%installer_target%"