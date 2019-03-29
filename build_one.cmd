rem @echo off
echo -
echo ------------------------------
echo building %1 
echo ------------------------------

set VERSION=%1

rem -- default options values
IF [%DEBUG_FLAG%] == [] GOTO DefineDefaultDEBUG_FLAG
goto DontDefineDefaultDEBUG_FLAG
:DefineDefaultDEBUG_FLAG
set DEBUG_FLAG=true
:DontDefineDefaultDEBUG_FLAG
echo DEBUG_FLAG = %DEBUG_FLAG%

IF [%MISSION_FILE%] == [] GOTO DefineDefaultMISSION_FILE
goto DontDefineDefaultMISSION_FILE
:DefineDefaultMISSION_FILE
set MISSION_FILE=.\build\OpenTraining_%VERSION%_%date:~-4,4%%date:~-10,2%%date:~-7,2%
:DontDefineDefaultMISSION_FILE
echo MISSION_FILE = %MISSION_FILE%.miz

IF ["%SEVENZIP%"] == [] GOTO DefineDefaultSEVENZIP
goto DontDefineDefaultSEVENZIP
:DefineDefaultSEVENZIP
set SEVENZIP=7za
:DontDefineDefaultSEVENZIP
echo SEVENZIP = %SEVENZIP%

rem -- copy all the source mission files
xcopy /y /e src\%VERSION% .\build\tempsrc\ 

rem -- copy all the community scripts
copy .\src\scripts\community\mist_4_3_74.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\community\WeatherMark.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\community\JTACAutoLase.lua .\build\tempsrc\l10n\Default  

rem -- copy all the scripts
copy .\src\scripts\dcsUnits.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veaf.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veaf_library.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafAssets.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafCarrierOperations.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafCasMission.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafGrass.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafMarkers.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafMove.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafNamedPoints.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafRadio.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafSpawn.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafTransportMission.lua .\build\tempsrc\l10n\Default  
copy .\src\scripts\veafUnits.lua .\build\tempsrc\l10n\Default  

rem -- set the debug flag to off
powershell -Command "(gc .\build\tempsrc\l10n\Default\veaf.lua) -replace 'veaf.Development = %DEBUG_FLAG%', 'veaf.Development = false' | sc .\build\tempsrc\l10n\Default\veaf.lua"

rem -- compile the mission
"%SEVENZIP%" a -r -tzip %MISSION_FILE%.miz .\build\tempsrc\* -mem=AES256

rem -- done !
echo Built %MISSION_FILE%.miz
