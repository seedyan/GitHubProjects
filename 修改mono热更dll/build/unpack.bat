cd apktool
set APK_NAME=%1
echo apktool unpack start
apktool d -s -f %~dp0apktool\%APK_NAME%.apk -o %~dp0apktool\%APK_NAME%
echo apktool unpack over