set apkname=%1
cd %~dp0
move %~dp0apktool\%apkname%\assets\bin\Data\Managed\Assembly-CSharp.dll %~dp0EncryptDll\EncryptDll\bin\Release
echo ####encryptdll
cd %~dp0EncryptDll\EncryptDll\bin\Release
call EncryptDll.bat
echo ####enctypy success
echo ####del unencryptdll
del Assembly-CSharp.dll 
echo ####rename encryptdll
ren Assembly-CSharp_Encrypt.dll Assembly-CSharp.dll
echo ####renturn encryptdll
move %~dp0EncryptDll\EncryptDll\bin\Release\Assembly-CSharp.dll %~dp0apktool\%apkname%\assets\bin\Data\Managed
echo ####change apktool.yml
xcopy /y %~dp0apktool\apktool.yml %~dp0apktool\%apkname%
echo ####change libmono.so
xcopy /y %~dp0libmono\armv7a\libmono.so %~dp0apktool\%apkname%\lib\armeabi-v7a\libmono.so
xcopy /y %~dp0libmono\x86\libmono.so %~dp0apktool\%apkname%\lib\x86\libmono.so
