set -e
echo $(whoami)

#cd ${WORKSPACE}
#pwd

APP_PROFILE="/apps/jenkins/SignIOS/Content_Transfer_Dev.mobileprovision"
IDENTITY="iPhone Developer: VZW Jenkins (79JJEEZ78Q)"

Build_Type=Store_Release
KEYCHAIN=/Users/jenkins/Library/Keychains/login.keychain
PROJECT=contenttransfer.xcodeproj
CONFIGURATION=${Build_Type}
TARGET=${Build_Target}

function extract_profile_id {
PROFILE=$1
cat ${PROFILE} | perl -ne 'if(/<key>UUID<.key>/){$_=<STDIN>; s/<string>(.+)<// && print $1;}'
}

APP_PROFILE_ID=$(extract_profile_id ${APP_PROFILE})

# Make sure the provisioning profiles are properly installed
#cp "${APP_PROFILE}" "$HOME/Library/MobileDevice/Provisioning Profiles/${APP_PROFILE_ID}.mobileprovision"
#echo "Installed ${APP_PROFILE} to $HOME/Library/MobileDevice/Provisioning Profiles/${APP_PROFILE_ID}.mobileprovision"

# unlock keychain if nessary, if your using the login keychain this shouldn't be nessary
#security unlock-keychain -p "${jenkins_password}" ${KEYCHAIN}



# clean the build
/usr/bin/xcodebuild -alltargets clean

# build the build
/usr/bin/xcodebuild \
-project "${PROJECT}" \
-configuration "${CONFIGURATION}" \
-scheme "CTstandalone" \
-archivePath "./build/${PROJECT}.xcarchive" \
CONFIGURATION_TEMP_DIR=./build \
archive

#CODE_SIGN_IDENTITY="${IDENTITY}" \

#name ipa build accordingly
NAME=${CONFIGURATION}

# export the archive
/usr/bin/xcodebuild \
-exportArchive \
-archivePath "./build/${PROJECT}.xcarchive" \
-exportPath "./build/${NAME}" \
-exportOptionsPlist "./exportOptions.plist"

#function extract_bundler_version {
#PLIST=$1
#cat ${PLIST} | perl -ne 'if(/<key>CFBundleVersion<.key>/){$_=<STDIN>; s/<string>(.+)<// && print $1;}'
#}

# Framework
if [[ "${FrameworkRelease}" = "true" ]]
then
echo "Build Framework"

# build the framework

/usr/bin/xcodebuild \
-project "${PROJECT}" \
-configuration "${CONFIGURATION}" \
-scheme "CTstandalone" \
CONFIGURATION_TEMP_DIR=./build/framework \
build
fi

echo $Version
echo $BUILD_TIMESTAMP
