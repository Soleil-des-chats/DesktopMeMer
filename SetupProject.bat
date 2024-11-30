@echo off
@title -- Setup Tool --
cls
echo ////////////////////////////////////////////////////////////////////
echo Titimousse Project Building Tool Setup
echo --- Building: DesktopMeMer ---	
echo ////////////////////////////////////////////////////////////////////
echo The setup process will begin. Press any key to continue.
pause > nul

REM Clone repository
if not exist TSdk (
    echo Cloning TSdk repository...
    git clone https://github.com/Soleil-des-chats/TSdk.git || (
        echo Error: Failed to clone TSdk repository. Exiting.
        pause > nul
        exit /b
    )
) else (
    echo TSdk repository already exists. Skipping clone.
)

REM Create Output directory
if exist Output (
    echo Cleaning existing Output directory...
    rmdir /s /q Output
)
mkdir Output
echo Output directory created.

REM Download NW.js SDK
cd Output
echo Downloading NW.js...
..\TSdk\wget.exe https://dl.nwjs.io/v0.91.0/nwjs-sdk-v0.91.0-win-x64.zip || (
    echo Error: Failed to download NW.js. Exiting.
    pause > nul
    exit /b
)

REM Extract NW.js SDK into Output folder
echo Extracting NW.js...
..\TSdk\7z.exe x nwjs-sdk-v0.91.0-win-x64.zip -o. > nul || (
    echo Error: Failed to extract NW.js. Exiting.
    pause > nul
    exit /b
)

REM Check if the subfolder exists before attempting to copy
if exist "nwjs-sdk-v0.91.0-win-x64" (
    REM Move contents from nwjs-sdk-v0.91.0-win-x64 to Output
    echo Moving files to Output...
    xcopy /E /H /K /Y "nwjs-sdk-v0.91.0-win-x64\*" ".\" > nul || (
        echo Error: Failed to move files. Exiting.
        pause > nul
        exit /b
    )

    REM Delete the empty subfolder
    rmdir /s /q "nwjs-sdk-v0.91.0-win-x64"
    echo Files moved and subfolder deleted successfully.
) else (
    echo Error: Subfolder 'nwjs-sdk-v0.91.0-win-x64' not found. Exiting.
    pause > nul
    exit /b
)

REM Remove the original zip file after extraction
del nwjs-sdk-v0.91.0-win-x64.zip
cd ..

REM Install npm dependencies
if exist src (
    echo Installing npm dependencies...
    cd src
    call npm install || (
        echo Error: npm install failed. Exiting.
        pause > nul
        exit /b
    )
    echo npm install completed successfully.
    cd ..
) else (
    echo Error: src directory not found. Exiting.
    pause > nul
    exit /b
)

REM Rename temporary build script
if exist BuildProject.temp (
    ren BuildProject.temp BuildProject.bat
    echo BuildProject.bat file created.
) else (
    echo Warning: BuildProject.temp file not found. Skipping rename.
)

echo Project Setup Completed
pause > nul
