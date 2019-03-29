@echo off
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

IF [%MISSION_FILE_SUFFIX%] == [] GOTO DefineDefaultMISSION_FILE_SUFFIX
goto DontDefineDefaultMISSION_FILE_SUFFIX
:DefineDefaultMISSION_FILE_SUFFIX
set MISSION_FILE_SUFFIX=%date:~-4,4%%date:~-7,2%%date:~-10,2%
:DontDefineDefaultMISSION_FILE_SUFFIX
set MISSION_FILE=.\build\OpenTraining_%VERSION%_%MISSION_FILE_SUFFIX%
echo MISSION_FILE = %MISSION_FILE%.miz

IF ["%SEVENZIP%"] == [] GOTO DefineDefaultSEVENZIP
goto DontDefineDefaultSEVENZIP
:DefineDefaultSEVENZIP
set SEVENZIP=7za
:DontDefineDefaultSEVENZIP
echo SEVENZIP = %SEVENZIP%

rem -- copy all the source mission files
xcopy /y /e src\%VERSION% .\build\tempsrc\ >nul 2>&1

rem -- copy all the community scripts
copy .\src\scripts\community\mist_4_3_74.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\community\WeatherMark.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\community\JTACAutoLase.lua .\build\tempsrc\l10n\Default  >nul 2>&1

rem -- copy all the scripts
copy .\src\scripts\dcsUnits.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veaf.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veaf_library.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafAssets.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafCarrierOperations.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafCasMission.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafGrass.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafMarkers.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafMove.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafNamedPoints.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafRadio.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafSpawn.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafTransportMission.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\src\scripts\veafUnits.lua .\build\tempsrc\l10n\Default  >nul 2>&1

rem -- set the debug flag to off
powershell -Command "(gc .\build\tempsrc\l10n\Default\veaf.lua) -replace 'veaf.Development = %DEBUG_FLAG%', 'veaf.Development = false' | sc .\build\tempsrc\l10n\Default\veaf.lua" >nul 2>&1

rem -- compile the mission
"%SEVENZIP%" a -r -tzip %MISSION_FILE%.miz .\build\tempsrc\* -mem=AES256 >nul 2>&1

rem -- done !
echo Built %MISSION_FILE%.miz
