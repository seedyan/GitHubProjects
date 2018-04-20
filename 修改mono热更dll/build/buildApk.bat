::echo off
set /p IF_BUNDLE=create assetbundle?(Y/N)
set APK_NAME=%1
set UNITY_PATH="C:\Program Files\Unity\Editor\Unity.exe"
cd..
set PRE_PATH=%cd%
set PROJECT_PATH="%PRE_PATH%\DOADemo"
cd build
set LOG_PATH=%cd%\unity_log.txt
set METHOD_NAME="ProjectBuild.BuildApk"
set APKPATH=%~dp0apktool\

echo ####start
%UNITY_PATH% -quit -batchmode -projectPath %PROJECT_PATH% -logFile %LOG_PATH% -executeMethod %METHOD_NAME% -apkpath %APKPATH% -bundle %IF_BUNDLE% -apkName %APK_NAME%

if %errorlevel% == 0 (echo success) else (echo faild unity_log.txt)
