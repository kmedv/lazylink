echo off

set LAUNCH_DIR=%CD%
set PRO_FPATH=%LAUNCH_DIR%\app\lazylink.pro
set QMAKE_STASH_DIR=app\.qmake_stash
set BUILD_DIR=app\build
set QML_DIR=app\qml
set OUT_DIR=out
set OUT_APP_DIR=%OUT_DIR%\app

echo Clearing old build...
rmdir /Q /S %OUT_DIR%
rmdir /Q /S %BUILD_DIR%
rmdir /Q /S %QMAKE_STASH_DIR%
echo Done.

echo Building the executable...
set QMAKE_ARGS=CONFIG+=release CONFIG+=x86_64
mkdir %BUILD_DIR%
cd %BUILD_DIR%
%QTDIR%/bin/qmake %PRO_FPATH% %QMAKE_ARGS%
nmake
cd %LAUNCH_DIR%
echo Done.

echo Deploying...
mkdir %OUT_APP_DIR%
copy /B /D /Y %BUILD_DIR%\release\lazylink.exe %OUT_APP_DIR%
%QTDIR%\bin\windeployqt.exe ^
    --release --force ^
    --angle --compiler-runtime --no-webkit2 --no-translations ^
    --qmldir %QML_DIR% ^
    --dir %OUT_APP_DIR% ^
    %OUT_APP_DIR%\lazylink.exe

copy /B /D /Y app\ext\ssleay\x64\* %OUT_APP_DIR%
copy /B /D /Y app\ext\WinSparkle\x64\Release\WinSparkle.dll %OUT_APP_DIR%
echo Done.

echo Deployment completed.
