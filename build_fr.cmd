@echo off
rem -- prepare the folders
rd /s /q .\build  >nul 2>&1
mkdir .\build  >nul 2>&1
mkdir .\build\tempsrc  >nul 2>&1

set MISSION_FILE=.\build\OT_Causacus_%date:~-4,4%%date:~-7,2%%date:~-10,2%
call build_one.cmd release
call build_one.cmd openbeta