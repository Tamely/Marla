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

set "PREMAKE_ACTION=%MARLA_PREMAKE_ACTION%"
if not defined PREMAKE_ACTION set "PREMAKE_ACTION=vs2026"

call "%~dp0Generate-Projects.bat" "%PREMAKE_ACTION%"
if errorlevel 1 exit /b %errorlevel%

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo Could not find vswhere.exe. Install Visual Studio with Desktop development with C++.
    exit /b 3
)

set "MSBUILD_PATH="
for /f "usebackq tokens=*" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
    if not defined MSBUILD_PATH set "MSBUILD_PATH=%%I"
)

if not defined MSBUILD_PATH (
    echo Could not find MSBuild. Install Visual Studio with Desktop development with C++.
    exit /b 3
)

set "SOLUTION_NAME=Marla.sln"
if /I "%PREMAKE_ACTION%"=="vs2026" set "SOLUTION_NAME=Marla.slnx"

echo Building Marla: %CONFIGURATION%
"%MSBUILD_PATH%" "%PROJECT_ROOT%\build\%PREMAKE_ACTION%\%SOLUTION_NAME%" /m /p:Configuration=%CONFIGURATION% /p:Platform=x64
if errorlevel 1 exit /b %errorlevel%

echo Build complete: %PROJECT_ROOT%\build\bin\%CONFIGURATION%-windows-x86_64
exit /b 0
