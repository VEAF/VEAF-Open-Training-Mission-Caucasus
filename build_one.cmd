rem @echo off
echo -
echo ------------------------------
echo building %1 
echo ------------------------------

IF [%VEAF_LIBRARY_FOLDER%] == [] GOTO DefineDefaultVEAF_LIBRARY_FOLDER
goto DontDefineDefaultVEAF_LIBRARY_FOLDER
:DefineDefaultVEAF_LIBRARY_FOLDER
set VEAF_LIBRARY_FOLDER=..\VEAF_mission_library
:DontDefineDefaultVEAF_LIBRARY_FOLDER
echo VEAF_LIBRARY_FOLDER = %VEAF_LIBRARY_FOLDER%

IF [%MISSION_FILE%] == [] GOTO DefineDefaultMISSION_FILE
goto DontDefineDefaultMISSION_FILE
:DefineDefaultMISSION_FILE
set MISSION_FILE=.\build\OT_Causacus_%date:~-4,4%%date:~-10,2%%date:~-7,2%
:DontDefineDefaultMISSION_FILE
echo MISSION_FILE = %MISSION_FILE%.miz

IF ["%SEVENZIP%"] == [] GOTO DefineDefaultSEVENZIP
goto DontDefineDefaultSEVENZIP
:DefineDefaultSEVENZIP
set SEVENZIP=7za
:DontDefineDefaultSEVENZIP
echo SEVENZIP = %SEVENZIP%

rem -- copy all the source mission files
xcopy /y /e src\%1 .\build\tempsrc\ >nul 2>&1

rem -- copy all the scripts
copy community\mist_4_3_74.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy community\WeatherMark.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\veaf.lua .\build\tempsrc\l10n\Default  >nul 2>&1
powershell -Command "(gc .\build\tempsrc\l10n\Default\veaf.lua) -replace 'veaf.Development = true', 'veaf.Development = false' | sc .\build\tempsrc\l10n\Default\veaf.lua"
copy %VEAF_LIBRARY_FOLDER%\scripts\veafMarkers.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\veafSpawn.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\veafCasMission.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\veafTransportMission.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\veafMove.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\veafGrass.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\veafUnits.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\veafCarrierOperations.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\dcsUnits.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy %VEAF_LIBRARY_FOLDER%\scripts\veafNamedPoints.lua .\build\tempsrc\l10n\Default  >nul 2>&1

rem -- compile the mission
"%SEVENZIP%" a -r -tzip %MISSION_FILE%_%1.miz .\build\tempsrc\* -mem=AES256

rem -- done !
echo Built %MISSION_FILE%_%1%.miz
