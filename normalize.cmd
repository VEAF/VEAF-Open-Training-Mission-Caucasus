rem -- parameter 1 is the name of the weather file

rem -- normalize and prepare the version
echo normalize and prepare the version for %1
pushd node_modules\veaf-mission-creation-tools\scripts\veaf
"%LUA%" veafMissionNormalizer.lua ..\..\..\..\build\tempsrc ..\..\..\..\src\weatherAndTime\%1.lua %LUA_SCRIPTS_DEBUG_PARAMETER%
popd

rem -- compile the mission
"%SEVENZIP%" a -r -tzip %MISSION_FILE%-%1.miz .\build\tempsrc\* -mem=AES256 >nul 2>&1

