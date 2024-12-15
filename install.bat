@echo off
setlocal

REM Define the target installation directory
set TARGET_DIR=C:\Byte-Ocelots

REM Create the target directory if it doesn't exist
if not exist "%TARGET_DIR%" (
    echo Creating installation directory at %TARGET_DIR%...
    mkdir "%TARGET_DIR%"
) else (
    echo Installation directory exists: %TARGET_DIR%
)

REM Copy the include directory and its subdirectories
if exist include (
    echo Copying include directory...
    xcopy /e /i include "%TARGET_DIR%\include"
) else (
    echo Include directory not found. Skipping...
)

REM Handle lib directory with possible subdirectories (x86_64 or i686)
if exist lib (
    echo Checking lib directory for architecture-specific subfolders...
    if exist lib\x86_64 (
        echo Copying lib\x86_64 directory...
        xcopy /e /i lib\x86_64 "%TARGET_DIR%\lib\x86_64"
    )
    if exist lib\i686 (
        echo Copying lib\i686 directory...
        xcopy /e /i lib\i686 "%TARGET_DIR%\lib\i686"
    )
    if not exist lib\x86_64 if not exist lib\i686 (
        echo No architecture-specific subdirectories found in lib. Copying all contents...
        xcopy /e /i lib "%TARGET_DIR%\lib"
    )
) else (
    echo Lib directory not found. Skipping...
)

REM Handle bin directory with possible subdirectories (win32 or win64)
if exist bin (
    echo Checking bin directory for platform-specific subfolders...
    if exist bin\win32 (
        echo Copying bin\win32 directory...
        xcopy /e /i bin\win32 "%TARGET_DIR%\bin\win32"
    )
    if exist bin\win64 (
        echo Copying bin\win64 directory...
        xcopy /e /i bin\win64 "%TARGET_DIR%\bin\win64"
    )
    if not exist bin\win32 if not exist bin\win64 (
        echo No platform-specific subdirectories found in bin. Copying all contents...
        xcopy /e /i bin "%TARGET_DIR%\bin"
    )
) else (
    echo Bin directory not found. Skipping...
)

REM Confirm successful installation
echo Installation complete! Files and directories have been installed to %TARGET_DIR%.

pause
