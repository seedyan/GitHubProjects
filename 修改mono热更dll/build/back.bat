set apkname=%1
cd %~dp0apktool
apktool b %apkname% -o %apkname%.apk
echo ####back to apk