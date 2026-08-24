@echo off
setlocal

set "PREMAKE_ACTION=%~1"
if not defined PREMAKE_ACTION set "PREMAKE_ACTION=vs2026"

call "%~dp0Generate-Projects.bat" "%PREMAKE_ACTION%"
if errorlevel 1 exit /b %errorlevel%

for %%I in ("%~dp0..") do set "PROJECT_ROOT=%%~fI"
set "SOLUTION_NAME=Marla.sln"
if /I "%PREMAKE_ACTION%"=="vs2026" set "SOLUTION_NAME=Marla.slnx"

start "" "%PROJECT_ROOT%\build\%PREMAKE_ACTION%\%SOLUTION_NAME%"
exit /b 0
