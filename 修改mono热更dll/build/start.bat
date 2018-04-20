::设置包名
set /p APK_NAME=apkname?
set /p ANDROID_NUM=android num?1 or 2 or 3?
::unity 打出apk
call buildApk.bat %APK_NAME%

::解包
call unpack.bat %APK_NAME%
cd %~dp0
::加密
call encryptDll.bat %APK_NAME%
cd %~dp0
::打回apk
call back.bat %APK_NAME%
cd %~dp0
::签名
call sign.bat %APK_NAME%
cd %~dp0
::移动文件夹
call movefile.bat %APK_NAME%,%ANDROID_NUM%
