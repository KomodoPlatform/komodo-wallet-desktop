#!/bin/bash

# Edited for KomodoPlatform/atomicDEX-Pro

set -x

# Original version is by Andy Maloney
# http://asmaloney.com/2013/07/howto/packaging-a-mac-os-x-application-using-a-dmg/

# make sure we are in the correct dir when we double-click a .command file
dir=${0%/*}
if [ -d "$dir" ]; then
  cd "$dir"
fi

# set up your app name, and background image file name
APP_NAME=$1
APP_FILE_NAME=$2
APP_PATH=$3
DMG_BACKGROUND_IMG="background.png"

# you should not need to change these
APP_EXE="${APP_PATH}${APP_FILE_NAME}.app/Contents/MacOS/${APP_FILE_NAME}"

VOL_NAME="${APP_NAME}"   # volume name will be 
DMG_TMP="${APP_PATH}${VOL_NAME}-temp.dmg"
DMG_FINAL="${APP_PATH}${VOL_NAME}.dmg"         # final DMG name will be ".dmg"
STAGING_DIR="./Install"             # we copy all our stuff into this dir

# Check the background image DPI and convert it if it isn't 72x72
_BACKGROUND_IMAGE_DPI_H=`sips -g dpiHeight ${DMG_BACKGROUND_IMG} | grep -Eo '[0-9]+\.[0-9]+'`
_BACKGROUND_IMAGE_DPI_W=`sips -g dpiWidth ${DMG_BACKGROUND_IMG} | grep -Eo '[0-9]+\.[0-9]+'`

if [ $(echo " $_BACKGROUND_IMAGE_DPI_H != 72.0 " | bc) -eq 1 -o $(echo " $_BACKGROUND_IMAGE_DPI_W != 72.0 " | bc) -eq 1 ]; then
   echo "WARNING: The background image's DPI is not 72.  This will result in distorted backgrounds on Mac OS X 10.7+."
   echo "         I will convert it to 72 DPI for you."
   
   _DMG_BACKGROUND_TMP="${DMG_BACKGROUND_IMG%.*}"_dpifix."${DMG_BACKGROUND_IMG##*.}"

   sips -s dpiWidth 72 -s dpiHeight 72 ${DMG_BACKGROUND_IMG} --out ${_DMG_BACKGROUND_TMP}
   
   DMG_BACKGROUND_IMG="${_DMG_BACKGROUND_TMP}"
fi

# clear out any old data
rm -rf "${STAGING_DIR}" "${DMG_TMP}" "${DMG_FINAL}"

# copy over the stuff we want in the final disk image to our staging dir
mkdir -p "${STAGING_DIR}"
cp -Rpf "${APP_PATH}${APP_FILE_NAME}.app" "${STAGING_DIR}"
# ... cp anything else you want in the DMG - documentation, etc.

pushd "${STAGING_DIR}"

## strip the executable
#echo "Stripping ${APP_EXE}..."
##strip -u -r "${APP_EXE}"


# ... optionally perform any other stripping/compressing of libs and executables

popd

# figure out how big our DMG needs to be
#  assumes our contents are at least 1M!
SIZE=`du -sh "${STAGING_DIR}" | sed 's/\([0-9\.]*\)M\(.*\)/\1/'` 
SIZE=`echo "${SIZE} + 10.0" | bc | awk '{print int($1+0.5)}'`

if [ $? -ne 0 ]; then
   echo "Error: Cannot compute size of staging dir"
   exit
fi

sleep 5
# create the temp DMG file
for i in {1..5}; do hdiutil create -srcfolder "${STAGING_DIR}" -volname "${VOL_NAME}" -fs HFS+ \
      -fsargs "-c c=64,a=16,e=16" -format UDRW -size ${SIZE}M "${DMG_TMP}" && break || echo "DMG create attempt $i" && sleep 15; done


echo "Created DMG: ${DMG_TMP}"

# mount it and save the device
DEVICE=$(hdiutil attach -readwrite -noverify "${DMG_TMP}" | \
         egrep '^/dev/' | sed 1q | awk '{print $1}')

sleep 2

# add a link to the Applications dir
echo "Add link to /Applications"
pushd /Volumes/"${VOL_NAME}"
ln -s /Applications
popd

# add a background image
mkdir /Volumes/"${VOL_NAME}"/.background
cp "${DMG_BACKGROUND_IMG}" /Volumes/"${VOL_NAME}"/.background/

# tell the Finder to resize the window, set the background,
#  change the icon size, place the icons in the right position, etc.
echo '
   tell application "Finder"
     tell disk "'${VOL_NAME}'"
           open
           set current view of container window to icon view
           set toolbar visible of container window to false
           set statusbar visible of container window to false
           set the bounds of container window to {400, 100, 910, 485}
           set viewOptions to the icon view options of container window
           set arrangement of viewOptions to not arranged
           set icon size of viewOptions to 72
           set background picture of viewOptions to file ".background:'${DMG_BACKGROUND_IMG}'"
           set position of item "'${APP_FILE_NAME}'.app" of container window to {130, 170}
           set position of item "Applications" of container window to {350, 170}
           set position of item ".background" of container window to {140, 600}
           set position of item ".fseventsd" of container window to {350, 600}
           close
           open
           update without registering applications
           delay 2
     end tell
   end tell
' | osascript

sync

# unmount it (5 chances, with some sleep to catch up)
for i in {1..5}; do hdiutil detach "${DEVICE}" && break || echo "unmount attempt $i" && sleep 15; done



# now make the final image a compressed disk image (5 chances, with some sleep to catch up)
echo "Creating compressed image"
for i in {1..5}; do hdiutil convert "${DMG_TMP}" -format UDZO -imagekey zlib-level=9 -o "${DMG_FINAL}" && break || echo "convert attempt $i" && sleep 15; done


# clean up
rm -rf "${DMG_TMP}"
rm -rf "${STAGING_DIR}"

echo 'Done.'

exit
