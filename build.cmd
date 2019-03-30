rem @echo off
echo -
echo ------------------------------
echo building OpenTraining
echo ------------------------------

rem -- prepare the folders
rd /s /q .\build  
mkdir .\build  
mkdir .\build\tempsrc  

call build_one.cmd caucasus
call build_one.cmd test