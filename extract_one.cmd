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
"%SEVENZIP%" x -y *.miz -o"%cd%\src\%1\mission\"
del /f /q src\%1\mission\l10n\Default\*.lua
del *.miz
