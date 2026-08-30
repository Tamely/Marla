@echo off
setlocal

call "%~dp0Scripts\Setup-Premake.bat"
if errorlevel 1 goto setup_failed

call "%~dp0Scripts\Setup-Dependencies.bat"
if errorlevel 1 goto setup_failed

set "MARLA_SKIP_SETUP=1"
call "%~dp0Scripts\Generate-Projects.bat" %*
if errorlevel 1 goto setup_failed

echo.
echo Marla setup completed successfully.
pause
exit /b 0

:setup_failed
set "SETUP_RESULT=%errorlevel%"
echo.
echo Marla setup failed with exit code %SETUP_RESULT%.
pause
exit /b %SETUP_RESULT%
