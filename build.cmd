@echo off
rem -- prepare the folders
rd /s /q .\build  >nul 2>&1
mkdir .\build  >nul 2>&1
mkdir .\build\tempsrc  >nul 2>&1

call build_one.cmd release
rem call build_one.cmd openbeta