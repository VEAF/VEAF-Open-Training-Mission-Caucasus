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
echo NOPAUSE if set to "true", will not pause at the end of the script (useful to chain calls to this script)
echo defaults to "false"
IF [%NOPAUSE%] == [] GOTO DefineDefaultNOPAUSE
goto DontDefineDefaultNOPAUSE
:DefineDefaultNOPAUSE
set NOPAUSE=false
:DontDefineDefaultNOPAUSE
echo current value is "%NOPAUSE%"

echo ----------------------------------------
echo VERBOSE_LOG_FLAG if set to "true", will create a mission with tracing enabled (meaning that, when run, it will log a lot of details in the dcs log file)
echo defaults to "false"
IF [%VERBOSE_LOG_FLAG%] == [] GOTO DefineDefaultVERBOSE_LOG_FLAG
goto DontDefineDefaultVERBOSE_LOG_FLAG
:DefineDefaultVERBOSE_LOG_FLAG
set VERBOSE_LOG_FLAG=false
:DontDefineDefaultVERBOSE_LOG_FLAG
echo current value is "%VERBOSE_LOG_FLAG%"

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
echo SECURITY_DISABLED_FLAG if set to "true", will create a mission with security disabled (meaning that no password is ever required)
echo defaults to "false"
IF [%SECURITY_DISABLED_FLAG%] == [] GOTO DefineDefaultSECURITY_DISABLED_FLAG
goto DontDefineDefaultSECURITY_DISABLED_FLAG
:DefineDefaultSECURITY_DISABLED_FLAG
set SECURITY_DISABLED_FLAG=false
:DontDefineDefaultSECURITY_DISABLED_FLAG
echo current value is "%SECURITY_DISABLED_FLAG%"

echo ----------------------------------------
echo SEVENZIP (a string) points to the 7za executable
echo defaults "7za", so it needs to be in the path
IF ["%SEVENZIP%"] == [""] GOTO DefineDefaultSEVENZIP
goto DontDefineDefaultSEVENZIP
:DefineDefaultSEVENZIP
set SEVENZIP=7za
:DontDefineDefaultSEVENZIP
echo current value is "%SEVENZIP%"

echo ----------------------------------------
echo LUA (a string) points to the lua executable
echo defaults "lua", so it needs to be in the path
IF ["%LUA%"] == [""] GOTO DefineDefaultLUA
goto DontDefineDefaultLUA
:DefineDefaultLUA
set LUA=lua
:DontDefineDefaultLUA
echo current value is "%LUA%"

echo ----------------------------------------
echo DYNAMIC_MISSION_PATH (a string) points to folder where this mission is located
echo defaults this folder
IF ["%DYNAMIC_MISSION_PATH%"] == [""] GOTO DefineDefaultDYNAMIC_MISSION_PATH
goto DontDefineDefaultDYNAMIC_MISSION_PATH
:DefineDefaultDYNAMIC_MISSION_PATH
set DYNAMIC_MISSION_PATH=%~dp0
:DontDefineDefaultDYNAMIC_MISSION_PATH
echo current value is "%DYNAMIC_MISSION_PATH%"

echo ----------------------------------------
echo DYNAMIC_SCRIPTS_PATH (a string) points to folder where the VEAF-mission-creation-tools are located
echo defaults this folder
IF ["%DYNAMIC_SCRIPTS_PATH%"] == [""] GOTO DefineDefaultDYNAMIC_SCRIPTS_PATH
goto DontDefineDefaultDYNAMIC_SCRIPTS_PATH
:DefineDefaultDYNAMIC_SCRIPTS_PATH
set DYNAMIC_SCRIPTS_PATH=%~dp0node_modules\veaf-mission-creation-tools\
set NPM_UPDATE=true
:DontDefineDefaultDYNAMIC_SCRIPTS_PATH
echo current value is "%DYNAMIC_SCRIPTS_PATH%"

echo ----------------------------------------
echo DYNAMIC_LOAD_SCRIPTS if set to "true", will create a mission with all the scripts loaded dynamically by default
echo defaults to "false"
IF [%DYNAMIC_LOAD_SCRIPTS%] == [] GOTO DefineDefaultDYNAMIC_LOAD_SCRIPTS
goto DontDefineDefaultDYNAMIC_LOAD_SCRIPTS
:DefineDefaultDYNAMIC_LOAD_SCRIPTS
set DYNAMIC_LOAD_SCRIPTS=false
:DontDefineDefaultDYNAMIC_LOAD_SCRIPTS
echo current value is "%DYNAMIC_LOAD_SCRIPTS%"

echo.
IF ["%NPM_UPDATE%"] == [""] GOTO DontNPM_UPDATE
echo fetching the veaf-mission-creation-tools package
if exist yarn.lock (
	call yarn upgrade
) else (
	call yarn install
)
goto DoNPM_UPDATE
:DontNPM_UPDATE
echo skipping npm update
:DoNPM_UPDATE

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
for %%f in (.\src\scripts\community\*.lua) do (
	if exist "%MISSION_PATH%\l10n\Default\%%~nxf" (
		echo deleting %%~nxf
		del /f /q "%MISSION_PATH%\l10n\Default\%%~nxf"
	)
)
for %%f in (.\src\scripts\*.lua) do (
	if exist "%MISSION_PATH%\l10n\Default\%%~nxf" (
		echo deleting %%~nxf
		del /f /q "%MISSION_PATH%\l10n\Default\%%~nxf"
	)
)
for %%f in (%DYNAMIC_SCRIPTS_PATH%\src\scripts\community\*.lua) do (
	if exist "%MISSION_PATH%\l10n\Default\%%~nxf" (
		echo deleting %%~nxf
		del /f /q "%MISSION_PATH%\l10n\Default\%%~nxf"
	)
)
echo deleting veaf-script*.lua
del /f /q "%MISSION_PATH%\l10n\Default\veaf-script*.lua"
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