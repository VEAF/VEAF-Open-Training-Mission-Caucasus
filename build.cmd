@echo off
echo -
echo ------------------------------
echo building OpenTraining
echo ------------------------------

rem -- prepare the folders
rd /s /q .\build  
mkdir .\build  
mkdir .\build\tempsrc  

echo fetching the veaf-mission-creation-tools package
call npm update

call build_one.cmd caucasus
call build_one.cmd persiangulf