@echo off

echo Gitting latest
call git pull

echo Copying Files
xcopy .vim %HOME% /F /E /I /H /R /Y /B /EXCLUDE:.xcopyignore
xcopy .vimrc %HOME% /F /E /I /H /R /Y /B /EXCLUDE:.xcopyignore
