@echo off
setlocal

set "PREMAKE_ACTION=%~1"
if not defined PREMAKE_ACTION set "PREMAKE_ACTION=vs2026"

if /I "%PREMAKE_ACTION%"=="vs2026" goto action_valid
if /I "%PREMAKE_ACTION%"=="vs2022" goto action_valid

echo Unsupported Visual Studio action: %PREMAKE_ACTION%
echo Expected vs2026 or vs2022.
exit /b 2

:action_valid
for %%I in ("%~dp0..") do set "PROJECT_ROOT=%%~fI"

set "SOLUTION_NAME=Marla.sln"
if /I "%PREMAKE_ACTION%"=="vs2026" set "SOLUTION_NAME=Marla.slnx"

if /I "%MARLA_SKIP_SETUP%"=="1" goto setup_complete

call "%~dp0Setup-Premake.bat"
if errorlevel 1 exit /b %errorlevel%

call "%~dp0Setup-Dependencies.bat"
if errorlevel 1 exit /b %errorlevel%

:setup_complete
pushd "%PROJECT_ROOT%"
echo Generating Marla for %PREMAKE_ACTION%
"%~dp0bin\premake5.exe" "%PREMAKE_ACTION%"
set "GENERATE_RESULT=%errorlevel%"
popd

if not "%GENERATE_RESULT%"=="0" exit /b %GENERATE_RESULT%

echo Solution generated at %PROJECT_ROOT%\build\%PREMAKE_ACTION%\%SOLUTION_NAME%
exit /b 0
