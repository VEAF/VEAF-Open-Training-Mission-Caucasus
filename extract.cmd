@echo off
set MISSION_NAME=VEAF_OpenTraining_Caucasus
echo.
echo ----------------------------------------
echo extracting %MISSION_NAME%
echo ----------------------------------------
echo.

rem -- default options values
echo This script can use these environment variables to customize its behavior :

echo ----------------------------------------
echo LUA_SCRIPTS_DEBUG_PARAMETER can be set to "-debug" or "-trace" (or not set) ; this will be passed to the lua helper scripts (e.g. veafMissionRadioPresetsEditor and veafMissionNormalizer)
echo defaults to not set
IF [%LUA_SCRIPTS_DEBUG_PARAMETER%] == [] GOTO DefineDefaultLUA_SCRIPTS_DEBUG_PARAMETER
goto DontDefineDefaultLUA_SCRIPTS_DEBUG_PARAMETER
:DefineDefaultLUA_SCRIPTS_DEBUG_PARAMETER
set LUA_SCRIPTS_DEBUG_PARAMETER=	
:DontDefineDefaultLUA_SCRIPTS_DEBUG_PARAMETER
echo current value is "%LUA_SCRIPTS_DEBUG_PARAMETER%"

echo ----------------------------------------
echo SEVENZIP (a string) points to the 7za executable
echo defaults "7za", so it needs to be in the path
IF [%SEVENZIP%] == [] GOTO DefineDefaultSEVENZIP
goto DontDefineDefaultSEVENZIP
:DefineDefaultSEVENZIP
set SEVENZIP=7za
:DontDefineDefaultSEVENZIP
echo current value is "%SEVENZIP%"

echo ----------------------------------------
echo LUA (a string) points to the lua executable
echo defaults "lua", so it needs to be in the path
IF [%LUA%] == [] GOTO DefineDefaultLUA
goto DontDefineDefaultLUA
:DefineDefaultLUA
set LUA=lua
:DontDefineDefaultLUA
echo current value is "%LUA%"
echo ----------------------------------------

echo.
echo fetching the veaf-mission-creation-tools package
call yarn install
rem echo on

rem extracting MIZ files
echo extracting MIZ files
set MISSION_PATH=%cd%\src\mission
"%SEVENZIP%" x -y *%MISSION_NAME%*.miz -o"%MISSION_PATH%\"

rem -- set the loading to static in the mission file
echo set the loading to static in the mission file
powershell -Command "(gc '%MISSION_PATH%\l10n\Default\dictionary') -replace 'return(\s*[^\s]+\s*)-- scripts', 'return false -- scripts' | sc '%MISSION_PATH%\l10n\Default\dictionary'"
powershell -Command "(gc '%MISSION_PATH%\l10n\Default\dictionary') -replace 'return(\s*[^\s]+\s*)-- config', 'return false -- config' | sc '%MISSION_PATH%\l10n\Default\dictionary'"

rem removing unwanted elements
echo removing unwanted elements
del /f /q "%MISSION_PATH%\l10n\Default\*.lua"
del /f /q "%MISSION_PATH%\options"
rd /s /q "%MISSION_PATH%\Config"
rd /s /q "%MISSION_PATH%\Scripts"
rd /s /q "%MISSION_PATH%\track"
rd /s /q "%MISSION_PATH%\track_data"

rem setting the radio presets according to the settings file
echo setting the radio presets according to the settings file
pushd node_modules\veaf-mission-creation-tools\src\scripts\veaf
"%LUA%" veafMissionRadioPresetsEditor.lua "%MISSION_PATH%" "%MISSION_PATH%\..\radio\radioSettings.lua" %LUA_SCRIPTS_DEBUG_PARAMETER%
popd

rem normalizing the mission files
echo normalizing the mission files
pushd node_modules\veaf-mission-creation-tools\src\scripts\veaf
"%LUA%" veafMissionNormalizer.lua "%MISSION_PATH%" %LUA_SCRIPTS_DEBUG_PARAMETER%
popd

rem -- cleanup
rem del *%MISSION_NAME%*.miz

echo.
echo ----------------------------------------
rem -- done !
echo Extracted %MISSION_NAME%
echo ----------------------------------------

pause