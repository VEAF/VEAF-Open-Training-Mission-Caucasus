rem @echo off
set VEAF_LIBRARY_FOLDER=..\VEAF_mission_library
set MISSION_FILE=.\build\OT_Causacus_%date:~-4,4%%date:~-10,2%%date:~-7,2%.miz

rem -- prepare the folders
rd /s /q .\build 
mkdir .\build 
mkdir .\build\tempsrc 

rem -- copy all the source mission files
xcopy /y /e src .\build\tempsrc\

rem -- copy all the scripts
copy community\mist_4_3_74.lua .\build\tempsrc\l10n\Default 
copy community\WeatherMark.lua .\build\tempsrc\l10n\Default 
copy %VEAF_LIBRARY_FOLDER%\scripts\veaf.lua .\build\tempsrc\l10n\Default 
copy %VEAF_LIBRARY_FOLDER%\scripts\veafMarkers.lua .\build\tempsrc\l10n\Default 
copy %VEAF_LIBRARY_FOLDER%\scripts\veafSpawn.lua .\build\tempsrc\l10n\Default 
copy %VEAF_LIBRARY_FOLDER%\scripts\veafCasMission.lua .\build\tempsrc\l10n\Default 
copy %VEAF_LIBRARY_FOLDER%\scripts\veafMove.lua .\build\tempsrc\l10n\Default 
copy %VEAF_LIBRARY_FOLDER%\scripts\veafGrass.lua .\build\tempsrc\l10n\Default 
copy %VEAF_LIBRARY_FOLDER%\scripts\veafUnits.lua .\build\tempsrc\l10n\Default 
copy %VEAF_LIBRARY_FOLDER%\scripts\dcsUnits.lua .\build\tempsrc\l10n\Default 

rem -- compile the mission
7z a -r -tzip %MISSION_FILE% .\build\tempsrc\* -mem=AES256

rem -- done !
echo Built %MISSION_FILE%
