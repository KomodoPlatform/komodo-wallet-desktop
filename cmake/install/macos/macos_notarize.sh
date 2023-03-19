#!/usr/bin/env bash

set -eu -o pipefail

OS=$(uname -s)
if [ ${OS} = "Darwin" ]; then PATH="$(brew --prefix)/opt/gnu-getopt/bin:$PATH"; fi
if [ ${OS} = "Darwin" ] && [ ! -f "$(brew --prefix)/opt/gnu-getopt/bin/getopt" ]; then
    echo "This script requires 'brew install gnu-getopt'" && exit 1
fi

! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo '`getopt --test` failed in this environment.'
    exit 1
fi

if ! command -v xq >/dev/null ; then
    echo "xq is required for this script, please install yq to get it: 'pip3 install yq'"
    exit 2
fi

OPTS=-h
LONGOPTS=app-specific-password:,apple-id:,primary-bundle-id:,target-binary:,asc-public-id:,help

! PARSED=$(getopt --options=$OPTS --longoptions=$LONGOPTS --name "$0" -- "$@" )
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    printf "\n\nFailed parsing options:\n"
    getopt --longoptions=$LONGOPTS --name "$0" -- "$@"
    exit 3
fi

eval set -- "$PARSED"

while true; do
    case "$1" in
    --app-specific-password)
        APP_SPECIFIC_PASSWORD=$2
        shift 2
        ;;
    --apple-id)
        APPLE_ID=$2
        shift 2
        ;;
    --primary-bundle-id)
        PRIMARY_BUNDLE_ID=$2
        shift 2
        ;;
    --target-binary)
        TARGET_BINARY=$2
        shift 2
        ;;
    --asc-public-id)
        ASC_PUBLIC_ID=$2
        shift 2
        ;;
    -h|--help)
        echo "Usage: $0 --app-specific-password=<apple_app_specific_password> --apple-id=<apple_id_email> --primary-bundle-id=<java-style-bundle-id> --target-binary=<TARGET_BINARY_FULLPATH>"
        echo "Example: $0 --app-specific-password=\$DDEV_MACOS_APP_PASSWORD --apple-id=accounts@drud.com --primary-bundle-id=com.ddev.ddev --target-binary=.gotmp/bin/darwin_amd64/ddev"
        exit 0
        ;;
    --)
        break;
    esac
done

set -o nounset

if ! codesign -v ${TARGET_BINARY} ; then
    echo "${TARGET_BINARY} is not signed"
    exit 4
fi

/usr/bin/ditto -c -k --keepParent ${TARGET_BINARY} ${TARGET_BINARY}.zip ;

echo "before xcrun"
# Submit the zipball and get REQUEST_UUID
SUBMISSION_INFO=$(xcrun altool --notarize-app --primary-bundle-id=${PRIMARY_BUNDLE_ID} --asc-public-id=${ASC_PUBLIC_ID} -u ${APPLE_ID} -p ${APP_SPECIFIC_PASSWORD} --file ${TARGET_BINARY}.zip) ;

if [ $? != 0 ]; then
    printf "Submission failed: $SUBMISSION_INFO \n"
    exit 5
fi

echo "SUBMISSION_INFO=$SUBMISSION_INFO"

REQUEST_UUID=$(echo ${SUBMISSION_INFO} | awk -F ' = ' '/RequestUUID/ {print $2}')
if [ -z "${REQUEST_UUID}" ]; then
    echo "Errors trying to upload ${TARGET_BINARY}.zip: ${SUBMISSION_INFO}"
    exit 6
fi

echo "REQUEST_UUID=$REQUEST_UUID"

# Wait for "Package Approved"
timeout 10m bash -c "
    while ! xcrun altool --notarization-info ${REQUEST_UUID} --username ${APPLE_ID} --password ${APP_SPECIFIC_PASSWORD} --output-format xml | grep -q 'Package Approved' ; do
        sleep 60;
    done"

echo "Package Approved: REQUEST_UUID=$REQUEST_UUID can be accessed with this query: xcrun altool --notarization-info $REQUEST_UUID --username ${APPLE_ID} --output-format xml --password app_specific_password"

# Wait until the response is filled out (https URL appears in output)
timeout 10m bash -c "
    while ! xcrun altool --notarization-info ${REQUEST_UUID} --username ${APPLE_ID} --password ${APP_SPECIFIC_PASSWORD} --output-format xml | grep -q 'https://osxapps-ssl.itunes.apple.com/itunes-assets' ; do
        sleep 5;
    done"

# Get logfileurl and make sure it doesn't have any issues
logfileurl=$(xcrun altool --notarization-info $REQUEST_UUID --username ${APPLE_ID} --password ${APP_SPECIFIC_PASSWORD} --output-format xml | xq .plist.dict.dict.string[1] | xargs)
echo "Notarization LogFileURL=$logfileurl for REQUEST_UUID=$REQUEST_UUID ";
log=$(curl -sSL $logfileurl)
issues=$(echo ${log} | jq -r .issues )
if [ "$issues" != "null" ]; then
    printf "There are issues with the notarization (${issues}), see $logfileurl\n"
    printf "=== Log output === \n${log}\n"
    exit 7;
fi;
