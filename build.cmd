@echo off

IF [%VEAF_LIBRARY_FOLDER%] == [] GOTO DefineDefaultVEAF_LIBRARY_FOLDER
goto DontDefineDefaultVEAF_LIBRARY_FOLDER
:DefineDefaultVEAF_LIBRARY_FOLDER
set VEAF_LIBRARY_FOLDER=..\VEAF_mission_library
:DontDefineDefaultVEAF_LIBRARY_FOLDER
echo VEAF_LIBRARY_FOLDER = %VEAF_LIBRARY_FOLDER%
IF [%MISSION_FILE%] == [] GOTO DefineDefaultMISSION_FILE
goto DontDefineDefaultMISSION_FILE
:DefineDefaultMISSION_FILE
set MISSION_FILE=.\build\OT_Causacus_%date:~-4,4%%date:~-10,2%%date:~-7,2%.miz
:DontDefineDefaultMISSION_FILE
echo MISSION_FILE = %MISSION_FILE%

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
