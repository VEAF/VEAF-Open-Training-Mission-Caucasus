@echo off
set ZIP=temp.zip
set MIZ=OT_Caucasus_%date:~-4,4%%date:~-10,2%%date:~-7,2%.miz
set MIZ_BUILD=test_%date:~-4,4%%date:~-10,2%%date:~-7,2%%time:~0,2%%time:~3,2%%time:~6,2%.miz

echo %MIZ%

rem build new MIZ
mkdir tempsrc
mkdir build
mkdir mission
xcopy /y /e src tempsrc\
copy community\mist_4_3_74.lua .\tempsrc\l10n\Default
copy scripts\VEAF_markers.lua .\tempsrc\l10n\Default
copy scripts\veaf_grass_runways.lua .\tempsrc\l10n\Default
copy scripts\marker.lua .\tempsrc\l10n\Default
copy community\WeatherMark.lua .\tempsrc\l10n\Default
pushd tempsrc
7za a -r ..\build\%ZIP% -mem=AES256 *
popd
rd /s /q tempsrc
copy build\%ZIP% build\%MIZ_BUILD%
copy build\%ZIP% mission\%MIZ%