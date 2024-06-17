echo off

set OUT_DIR=%cd%\out
set DEPLOYABLE_DIR=%cd%\out\app
set INSTALLER_DIR=%cd%\installer
set INSTALLER_PACKAGES_DIR=
set PACKAGE_DIR=%INSTALLER_DIR%\packages\net.lazylink.app
set PACKAGE_DIR_DATA=%PACKAGE_DIR%\data

echo Preparing metadata...
copy /B /D /Y EULA %PACKAGE_DIR%\meta\EULA
echo Done.

echo Preparing data...
rmdir /Q /S %PACKAGE_DIR_DATA%
mkdir %PACKAGE_DIR_DATA%
%QIFDIR%\bin\archivegen %PACKAGE_DIR_DATA%\lazylink.7z %DEPLOYABLE_DIR%\*
echo Done

echo Building the installer executable...
%QIFDIR%\bin\binarycreator -f ^
    -c %INSTALLER_DIR%\config\config.xml ^
    -p %INSTALLER_DIR%\packages ^
    %OUT_DIR%\lazylink-setup.exe
echo Done.

echo Cleaning...
del %PACKAGE_DIR%\meta\EULA
rmdir /Q /S %PACKAGE_DIR_DATA%
echo Done.

echo Deployment completed.
