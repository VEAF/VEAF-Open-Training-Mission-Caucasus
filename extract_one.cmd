@echo off
echo -
echo ------------------------------
echo extracting %1 
echo ------------------------------

rem extracting MIZ files
pushd src\%1
"%SEVENZIP%" x -y ../../*.miz
del /f /q l10n\Default\*.lua 
popd
del *.miz
