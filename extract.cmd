@echo off
set MIZ=to_extract.miz

rem extracting MIZ files
pushd src
7za x -y ../%MIZ%
del /f /q l10n\Default\mist_4_3_74.lua 
del /f /q l10n\Default\veaf.lua 
del /f /q l10n\Default\veafCasMission.lua 
del /f /q l10n\Default\veafMarkers.lua 
del /f /q l10n\Default\veafSpawn.lua 
del /f /q l10n\Default\veafMove.lua 
del /f /q l10n\Default\\veafGrass.lua
del /f /q l10n\Default\\WeatherMark.lua
popd
