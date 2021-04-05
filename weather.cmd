@echo off
set MISSION_NAME=VEAF_OpenTraining_Caucasus
echo.
echo ----------------------------------------
echo building %MISSION_NAME%
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
echo ----------------------------------------
echo MISSION_FILE_SUFFIX1 (a string) will be appended to the mission file name to make it more unique
echo defaults to empty
IF [%MISSION_FILE_SUFFIX1%] == [] GOTO DefineDefaultMISSION_FILE_SUFFIX1
goto DontDefineDefaultMISSION_FILE_SUFFIX1
:DefineDefaultMISSION_FILE_SUFFIX1
set MISSION_FILE_SUFFIX1=
:DontDefineDefaultMISSION_FILE_SUFFIX1
echo current value is "%MISSION_FILE_SUFFIX1%"

echo ----------------------------------------
echo MISSION_FILE_SUFFIX2 (a string) will be appended to the mission file name to make it more unique
echo defaults to the current iso date
IF [%MISSION_FILE_SUFFIX2%] == [] GOTO DefineDefaultMISSION_FILE_SUFFIX2
goto DontDefineDefaultMISSION_FILE_SUFFIX2
:DefineDefaultMISSION_FILE_SUFFIX2
set TIMEBUILD=%TIME: =0%
set MISSION_FILE_SUFFIX2=%date:~-4,4%%date:~-7,2%%date:~-10,2%
:DontDefineDefaultMISSION_FILE_SUFFIX2
echo current value is "%MISSION_FILE_SUFFIX2%"

echo ----------------------------------------

IF [%MISSION_FILE_SUFFIX1%] == [] GOTO DontUseSuffix1
set MISSION_FILE=.\build\%MISSION_NAME%_%MISSION_FILE_SUFFIX1%_%MISSION_FILE_SUFFIX2%
goto EndOfSuffix1
:DontUseSuffix1
set MISSION_FILE=.\build\%MISSION_NAME%_%MISSION_FILE_SUFFIX2%
:EndOfSuffix1

rem -- generate the time and weather versions
echo generate the time and weather versions
echo ----------------------------------------
node node_modules\veaf-mission-creation-tools\src\nodejs\app.js injectall --quiet "%MISSION_FILE%.miz" "%MISSION_FILE%-${version}.miz" src\weatherAndTime\versions.json


IF [%NOPAUSE%] == [true] GOTO EndOfFile
pause
:EndOfFile