#!/bin/bash

build_folder=./build-Release/bin/AntaraAtomicDexAppDir/usr
root_folder=./installer
icon_file=app_icon.ico
installer_target=$root_folder/AtomicDEX-Pro-Installer
installer_folder=$root_folder/linux
installer_data=$installer_folder/packages/com.komodoplatform.atomicdexpro/data
config_file=$installer_folder/config/config.xml
packages_folder=$installer_folder/packages

# Delete old data
rm -rf "$installer_data"

# Copy new data
cp -r "$build_folder" "$installer_data"

# Copy icon
cp "$root_folder/$icon_file" "$installer_data"

# Create
$QT_IFW_PATH/bin/binarycreator -c "$config_file" -p "$packages_folder" "$installer_target"

echo $installer_target