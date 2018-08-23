@echo off
set MIZ=to_extract.miz

rem extracting MIZ files
pushd src
7za x -y ../%MIZ%
del /f /q l10n\Default\mist_4_3_74.lua 
del /f /q l10n\Default\\VEAF_markers.lua
del /f /q l10n\Default\\WeatherMark.lua
popd
