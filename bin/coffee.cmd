@echo off
ECHO 'hello'
ECHO %*
ECHO %~dp0
REM "C:\Program Files\nodejs\node.exe" "E:\readonly\coffeescript\bin\coffee" -v
"C:\Program Files\nodejs\node.exe" "E:\github\coffeescript\bin\coffee" %*
