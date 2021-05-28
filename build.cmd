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

echo.
echo Building %MISSION_FILE%.miz

echo.
echo prepare the folders
rd /s /q .\build
mkdir .\build

IF ["%NPM_UPDATE%"] == [""] GOTO DontNPM_UPDATE
echo fetch the veaf-mission-creation-tools package
call npm update
goto DoNPM_UPDATE
:DontNPM_UPDATE
echo skipping npm update
:DoNPM_UPDATE

echo prepare the veaf-mission-creation-tools scripts
rem -- copy the scripts folder
xcopy /s /y /e %DYNAMIC_SCRIPTS_PATH%\src\scripts\* .\build\tempscripts\ >nul 2>&1

rem -- set the flags in the scripts according to the options
echo set the flags in the scripts according to the options
powershell -File replace.ps1 .\build\tempscripts\veaf\veaf.lua "veaf.Development = (true|false)" "veaf.Development = %VERBOSE_LOG_FLAG%" >nul 2>&1
powershell -File replace.ps1 .\build\tempscripts\veaf\veaf.lua "veaf.SecurityDisabled = (true|false)" "veaf.SecurityDisabled = %SECURITY_DISABLED_FLAG%" >nul 2>&1

if %VERBOSE_LOG_FLAG%==false (
	rem -- comment all the trace and debug code
	echo comment all the trace and debug code
	FOR %%f IN (.\build\tempscripts\veaf\*.lua) DO powershell -File replace.ps1 %%f "(^\s*)(veaf.*\.[^\(^\s]*log(Trace|Debug|Marker))" "$1--$2" >nul 2>&1
)

echo building the mission
rem -- copy all the source mission files and mission-specific scripts
xcopy /y /e src\mission .\build\tempsrc\ >nul 2>&1
xcopy /y src\options .\build\tempsrc\  >nul 2>&1
xcopy /y /e src\scripts\*.lua .\build\tempsrc\l10n\Default\  >nul 2>&1

rem -- set the radio presets according to the settings file
echo set the radio presets according to the settings file
pushd %DYNAMIC_SCRIPTS_PATH%\src\scripts\veaf
"%LUA%" veafMissionRadioPresetsEditor.lua  %DYNAMIC_MISSION_PATH%\build\tempsrc %DYNAMIC_MISSION_PATH%\src\radio\radioSettings.lua %LUA_SCRIPTS_DEBUG_PARAMETER%
popd

rem -- set the dynamic load variables in the dictionary
echo set the dynamic load variables in the dictionary
powershell -Command "$temp='VEAF_DYNAMIC_PATH = [[' + [regex]::escape('%DYNAMIC_SCRIPTS_PATH%') + ']]'; (gc .\build\tempsrc\mission) -replace 'VEAF_DYNAMIC_PATH(\s*)=(\s*)\[\[.*\]\]', $temp | sc .\build\tempsrc\mission" >nul 2>&1
powershell -Command "$temp='VEAF_DYNAMIC_MISSIONPATH = [[' + [regex]::escape('%DYNAMIC_MISSION_PATH%') + ']]'; (gc .\build\tempsrc\mission) -replace 'VEAF_DYNAMIC_MISSIONPATH(\s*)=(\s*)\[\[.*\]\]', $temp | sc .\build\tempsrc\mission" >nul 2>&1

rem -- disable the C130 module requirement
powershell -File replace.ps1 .\build\tempsrc\mission "\[\"Hercules\"\] = \"Hercules\"," " " >nul 2>&1

rem -- disable the A-4E-C module requirement
powershell -File replace.ps1 .\build\tempsrc\mission "\[\"A-4E-C\"\] = \"A-4E-C\"," " " >nul 2>&1

rem -- disable the T-45 module requirement
powershell -File replace.ps1 .\build\tempsrc\mission "\[\"T-45\"\] = \"T-45\"," " " >nul 2>&1

rem -- copy the documentation images to the kneeboard
xcopy /y /e doc\*.jpg .\build\tempsrc\KNEEBOARD\IMAGES\ >nul 2>&1

rem -- copy all the community scripts
copy .\src\scripts\community\*.lua .\build\tempsrc\l10n\Default  >nul 2>&1
copy .\build\tempscripts\community\*.lua .\build\tempsrc\l10n\Default >nul 2>&1

rem -- copy all the common scripts
copy .\build\tempscripts\veaf\*.lua .\build\tempsrc\l10n\Default >nul 2>&1

rem -- normalize the mission files
pushd %DYNAMIC_SCRIPTS_PATH%\src\scripts\veaf
"%LUA%" veafMissionNormalizer.lua %DYNAMIC_MISSION_PATH%\build\tempsrc %LUA_SCRIPTS_DEBUG_PARAMETER%
popd

rem -- compile the mission
"%SEVENZIP%" a -r -tzip %MISSION_FILE%.miz .\build\tempsrc\* -mem=AES256 >nul 2>&1

rem -- cleanup the mission files
rd /s /q .\build\tempsrc

rem -- cleanup the veaf-mission-creation-tools scripts
rd /s /q .\build\tempscripts

rem -- generate the time and weather versions
rem echo generate the time and weather versions
rem echo ----------------------------------------
rem we'll do it on the server
rem node node_modules\veaf-mission-creation-tools\src\nodejs\app.js injectall --quiet "%MISSION_FILE%.miz" "%MISSION_FILE%-${version}.miz" src\weatherAndTime\versions.json

echo.
echo ----------------------------------------
rem -- done !
echo Built %MISSION_FILE%.miz
echo ----------------------------------------
echo.

IF [%NOPAUSE%] == [true] GOTO EndOfFile
pause
:EndOfFile