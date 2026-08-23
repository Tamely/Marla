@echo off
setlocal

set "CONFIGURATION=%~1"
if not defined CONFIGURATION set "CONFIGURATION=Debug"

if /I "%CONFIGURATION%"=="Debug" (
    set "CONFIGURATION=Debug"
    goto configuration_valid
)
if /I "%CONFIGURATION%"=="Release" (
    set "CONFIGURATION=Release"
    goto configuration_valid
)
if /I "%CONFIGURATION%"=="Shipping" (
    set "CONFIGURATION=Shipping"
    goto configuration_valid
)

echo Unknown configuration: %CONFIGURATION%
echo Expected Debug, Release, or Shipping.
exit /b 2

:configuration_valid
for %%I in ("%~dp0..") do set "PROJECT_ROOT=%%~fI"
pushd "%PROJECT_ROOT%"

echo Configuring Marla: %CONFIGURATION%
cmake --preset "%CONFIGURATION%"
if errorlevel 1 goto build_failed

echo Building Marla: %CONFIGURATION%
cmake --build --preset "%CONFIGURATION%" --parallel
if errorlevel 1 goto build_failed

echo Build complete: %PROJECT_ROOT%\build
popd
exit /b 0

:build_failed
set "BUILD_RESULT=%errorlevel%"
popd
exit /b %BUILD_RESULT%
