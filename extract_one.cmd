@echo off
echo -
echo ------------------------------
echo extracting %1 
echo ------------------------------

rem -- default options values
IF [%SEVENZIP%] == [] GOTO DefineDefaultSEVENZIP
goto DontDefineDefaultSEVENZIP
:DefineDefaultSEVENZIP
set SEVENZIP=7za
:DontDefineDefaultSEVENZIP
echo SEVENZIP = %SEVENZIP%
rem extracting MIZ files
pushd src\%1
"%SEVENZIP%" x -y ../../*.miz
del /f /q l10n\Default\*.lua 
popd
del *.miz
