set apkname=%1
cd %~dp0apktool
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore debug.keystore -storepass android %apkname%.apk androiddebugkey
echo ####sign success