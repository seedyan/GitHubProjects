echo create file %~dp0apk\%1_Android_%2

if exist %~dp0apk\%1_Android_%2 (
rd /s /q %~dp0apk\%1_Android_%2
)
md %~dp0apk\%1_Android_%2
move %~dp0apktool\%1\assets\bin\Data\Managed\Assembly-CSharp.dll %~dp0apk\%1_Android_%2
move %~dp0apktool\%1.apk %~dp0apk\%1_Android_%2
