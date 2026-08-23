@echo off
call "%~dp0Build.bat" Release
exit /b %errorlevel%
