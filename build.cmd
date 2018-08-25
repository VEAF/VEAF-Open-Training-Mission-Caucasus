@echo off
set ZIP=temp.zip
set MIZ=test_%date:~-4,4%%date:~-10,2%%date:~-7,2%.miz
set MIZ_BUILD=test_%date:~-4,4%%date:~-10,2%%date:~-7,2%%time:~0,2%%time:~3,2%%time:~6,2%.miz

echo %MIZ%

rem build new MIZ
rd /s /q tempsrc
mkdir tempsrc
rd /s /q build
mkdir build
rd /s /q mission
mkdir mission
xcopy /y /e src tempsrc\
copy community\mist_4_3_74.lua .\tempsrc\l10n\Default
copy scripts\veaf.lua .\tempsrc\l10n\Default
copy scripts\veafMarkers.lua .\tempsrc\l10n\Default
copy scripts\veafSpawn.lua .\tempsrc\l10n\Default
copy scripts\veafCasMission.lua .\tempsrc\l10n\Default
pushd tempsrc
7za a -r ..\build\%ZIP% -mem=AES256 *
popd
rd /s /q tempsrc
copy build\%ZIP% mission\%MIZ%
rd /s /q build
