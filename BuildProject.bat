@echo off
@title -- Build Tool --
cls

echo ////////////////////////////////////////////////////////////////////
echo Titimousse Project Building Tool
echo --- Building: DesktopMeMer ---
echo ////////////////////////////////////////////////////////////////////

rem Ask user to confirm and start the build
echo The build will begin. Press any key to continue...
pause >nul

rem Move to the source directory
cd /d "%~dp0src" || (
    echo Error: Could not find the source directory. Exiting...
    exit /b 1
)

rem Create a .zip of the source files
echo Creating the app.nw archive...
..\TSdk\7z a -tzip ..\Output\app.nw * -r || (
    echo Error: Failed to create app.nw. Exiting...
    exit /b 1
)

rem Move back to the root project directory
cd /d "%~dp0" || (
    echo Error: Failed to return to the root directory. Exiting...
    exit /b 1
)

rem Copy node_modules to the Output directory
echo Copying node_modules...
xcopy /i /e /h /y src\node_modules Output\node_modules || (
    echo Error: Failed to copy node_modules. Exiting...
    exit /b 1
)

rem Move to the Output directory
cd /d "%~dp0Output" || (
    echo Error: Could not find the Output directory. Exiting...
    exit /b 1
)

rem Combine nw.exe and app.nw to create app.exe
echo Combining nw.exe and app.nw to create app.exe...
copy /b nw.exe+app.nw app.exe || (
    echo Error: Failed to combine nw.exe and app.nw. Exiting...
    exit /b 1
)

rem Rename nw.exe to cleanNW.old_exe
echo Renaming nw.exe to cleanNW.old_exe...
ren nw.exe cleanNW.old_exe || (
    echo Error: Failed to rename nw.exe. Exiting...
    exit /b 1
)

rem Project setup completed
echo Project Setup Completed.
pause >nul
