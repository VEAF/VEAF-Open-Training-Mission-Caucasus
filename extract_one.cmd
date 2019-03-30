@echo off
echo -
echo ------------------------------
echo extracting %1 
echo ------------------------------

set MIZ=extract.miz

rem extracting MIZ files
pushd src\%1
"%SEVENZIP%" x -y ../../%MIZ%
del /f /q l10n\Default\*.lua 
popd
