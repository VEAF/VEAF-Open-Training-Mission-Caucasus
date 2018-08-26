-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF spawn command and functions for DCS World
-- By zip (2018)
--
-- Features:
-- ---------
-- * Listen to marker change events and execute spawn commands, with optional parameters
-- * Possibilities : 
-- *    - spawn a specific ennemy unit
-- *    - create a cargo drop to be picked by a helo
-- * Works with all current and future maps (Caucasus, NTTR, Normandy, PG, ...)
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires the base veaf.lua script library (version 1.0 or higher)
-- * It also requires the base veafMarkers.lua script library (version 1.0 or higher)
--
-- Load the script:
-- ----------------
-- 1.) Download the script and save it anywhere on your hard drive.
-- 2.) Open your mission in the mission editor.
-- 3.) Add a new trigger:
--     * TYPE   "4 MISSION START"
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of MIST and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of veaf.lua and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of veafMarkers.lua and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of this script and click OK.
--     * ACTION "DO SCRIPT"
--     * set the script command to "veafSpawn.initialize()" and click OK.
-- 4.) Save the mission and start it.
-- 5.) Have fun :)
--
-- Basic Usage:
-- ------------
-- 1.) Place a mark on the F10 map.
-- 2.) As text enter "veaf spawn unit" or "veaf spawn cargo"
-- 3.) Click somewhere else on the map to submit the new text.
-- 4.) The command will be processed. A message will appear to confirm this
-- 5.) The original mark will disappear.
--
-- Options:
-- --------
-- Type "veaf spawn unit, type [unit type]" to spawn a specific unit ; types can be any DCS type
-- Type "veaf spawn cargo, type [cargo type]" to spawn a specific cargo ; types can be any of [ammo, barrels, container, fbar, fueltank, m117, oiltank, uh1h]
--      add ", smoke" to add a smoke marker
--
-- *** NOTE ***
-- * All keywords are CaSE inSenSITvE.
-- * Commas are the separators between options ==> They are IMPORTANT!
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- veafSpawn Table.
veafSpawn = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafSpawn.Id = "SPAWN - "

--- Version.
veafSpawn.Version = "1.0.0"

--- Key phrase to look for in the mark text which triggers the weather report.
veafSpawn.Keyphrase = "veaf spawn "

--- Name of the spawned units group 
veafSpawn.RedSpawnedUnitsGroupName = "VEAF Spawned Units"

--- Illumination flare default initial altitude (in meters AGL)
veafSpawn.IlluminationFlareAglAltitude = 1000

veafSpawn.RadioMenuName = "SPAWN (" .. veafSpawn.Version .. ")"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafSpawn.rootPath = nil

-- counts the units generated 
veafSpawn.spawnedUnitsCounter = 0

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafSpawn.logInfo(message)
    veaf.logInfo(veafSpawn.Id .. message)
end

function veafSpawn.logDebug(message)
    veaf.logDebug(veafSpawn.Id .. message)
end

function veafSpawn.logTrace(message)
    veaf.logTrace(veafSpawn.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event handler functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Function executed when a mark has changed. This happens when text is entered or changed.
function veafSpawn.onEventMarkChange(eventPos, event)
    -- Check if marker has a text and the veafSpawn.keyphrase keyphrase.
    if event.text ~= nil and event.text:lower():find(veafSpawn.Keyphrase) then

        -- Analyse the mark point text and extract the keywords.
        local options = veafSpawn.markTextAnalysis(event.text)

        if options then
            -- Check options commands
            if options.unit then
                veafSpawn.spawnUnit(eventPos, options.unitType)
            elseif options.cargo then
                veafSpawn.spawnCargo(eventPos, options.cargoType, options.cargoSmoke)
            elseif options.smoke then
                veafSpawn.spawnSmoke(eventPos, options.smokeColor)
            elseif options.flare then
                veafSpawn.spawnIlluminationFlare(eventPos, options.alt)
            end
        else
            -- None of the keywords matched.
            return
        end

        -- Delete old mark.
        veafSpawn.logDebug(string.format("Removing mark # %d.", event.idx))
        trigger.action.removeMark(event.idx)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Analyse the mark text and extract keywords.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Extract keywords from mark text.
function veafSpawn.markTextAnalysis(text)

    -- Option parameters extracted from the mark text.
    local switch = {}
    switch.unit = false
    switch.cargo = false
    switch.smoke = false
    switch.flare = false

    -- spawned unit type
    switch.unitType = "BTR-80"

    -- smoke color
    switch.smokeColor = trigger.smokeColor.Red

    -- optional cargo smoke
    switch.cargoSmoke = false

    -- cargo type
    switch.cargoType = "uh1h_cargo"

    -- flare agl altitude (meters)
    switch.alt = veafSpawn.IlluminationFlareAglAltitude

    -- Check for correct keywords.
    if text:lower():find(veafSpawn.Keyphrase .. "unit") then
        switch.unit = true
    elseif text:lower():find(veafSpawn.Keyphrase .. "smoke") then
        switch.smoke = true
    elseif text:lower():find(veafSpawn.Keyphrase .. "flare") then
        switch.flare = true
    elseif text:lower():find(veafSpawn.Keyphrase .. "cargo") then
        switch.cargo = true
    else
        return nil
    end

    -- keywords are split by ","
    local keywords = veaf.split(text, ",")

    for _, keyphrase in pairs(keywords) do
        -- Split keyphrase by space. First one is the key and second, ... the parameter(s) until the next comma.
        local str = veaf.split(veaf.trim(keyphrase), " ")
        local key = str[1]
        local val = str[2]

        if switch.unit and key:lower() == "type" then
            -- Set unit type.
            veafSpawn.logDebug(string.format("Keyword type = %s", val))
            switch.unitType = val
        end

        if switch.smoke and key:lower() == "color" then
            -- Set smoke color.
            veafSpawn.logDebug(string.format("Keyword color = %s", val))
            if (val:lower() == "red") then 
                switch.smokeColor = trigger.smokeColor.Red
            elseif (val:lower() == "green") then 
                switch.smokeColor = trigger.smokeColor.Green
            elseif (val:lower() == "orange") then 
                switch.smokeColor = trigger.smokeColor.Orage
            elseif (val:lower() == "blue") then 
                switch.smokeColor = trigger.smokeColor.Blue
            elseif (val:lower() == "white") then 
                switch.smokeColor = trigger.smokeColor.White
            end
        end

        if switch.flare and key:lower() == "alt" then
            -- Set size.
            veafSpawn.logDebug(string.format("Keyword alt = %d", val))
            local nVal = tonumber(val)
            switch.alt = nVal
        end

        if switch.cargo and key:lower() == "type" then
            -- Set cargo type.
            veafSpawn.logDebug(string.format("Keyword type = %s", val))
            if val:lower() == "ammo" then
                switch.cargoType = "ammo_cargo"
            elseif val:lower() == "barrels" then
                switch.cargoType = "barrels_cargo"
            elseif val:lower() == "container" then
                switch.cargoType = "container_cargo"
            elseif val:lower() == "fbar" then
                switch.cargoType = "f_bar_cargo"
            elseif val:lower() == "fueltank" then
                switch.cargoType = "fueltank_cargo"
            elseif val:lower() == "m117" then
                switch.cargoType = "m117_cargo"
            elseif val:lower() == "oiltank" then
                switch.cargoType = "oiltank_cargo"
            elseif val:lower() == "uh1h" then
                switch.cargoType = "uh1h_cargo"            
            end
        end

        if switch.cargo and key:lower() == "smoke" then
            -- Mark with green smoke.
            veafSpawn.logDebug("Keyword smoke is set")
            switch.cargoSmoke = true
        end
    end

    return switch
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Unit spawn command
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Spawn a specific unit at a specific spot
function veafSpawn.spawnUnit(spawnSpot, unitType)
    veafSpawn.logDebug("spawnUnit(unitType = " .. unitType .. ")")
    veafSpawn.logDebug(string.format("spawnUnit: spawnSpot  x=%.1f y=%.1f, z=%.1f", spawnSpot.x, spawnSpot.y, spawnSpot.z))
    
    veafSpawn.spawnedUnitsCounter = veafSpawn.spawnedUnitsCounter + 1

    local isShip = false
    local units = {}
    
    if unitType == "VINSON" or  unitType == "PERRY" or unitType == "TICONDEROG" or unitType == "ALBATROS" or unitType == "KUZNECOW" or unitType == "MOLNIYA" or unitType == "MOSCOW" or unitType == "NEUSTRASH" or unitType == "PIOTR" or unitType == "REZKY" or unitType == "ELNYA" or unitType == "Dry-cargo ship-2" or unitType == "Dry-cargo ship-1" or unitType == "ZWEZDNY" or unitType == "KILO" or unitType == "SOM" or unitType == "speedboat" then
        isShip = true
    end
    veafSpawn.logDebug("spawnUnit isShip = " .. tostring(isShip))
    
    local groupName = veafSpawn.RedSpawnedUnitsGroupName .. " #" .. veafSpawn.spawnedUnitsCounter
    local unitName = groupName

    local spawnPosition = veaf.findPointInZone(spawnSpot, 50, isShip)
    if spawnPosition == nil then
        if isShip then 
            veafSpawn.logInfo("cannot find a suitable position for spawning naval unit "..unitType)
            trigger.action.outText("cannot find a suitable position for spawning naval unit "..unitType, 5)
            return
        else
            veafSpawn.logInfo("cannot find a suitable position for spawning ground unit "..unitType)
            trigger.action.outText("cannot find a suitable position for spawning ground unit "..unitType, 5)
            return
        end
    end  

    if spawnPosition ~= nil then
        table.insert(
            units,
            {
                ["x"] = spawnPosition.x,
                ["y"] = spawnPosition.y,
                ["type"] = unitType,
                ["name"] = unitName,
                ["heading"] = 0,
                ["skill"] = "Random"
            }
        )
    end

    -- actually spawn the unit
    if isShip then
        mist.dynAdd({country = "RUSSIA", category = "SHIP", name = groupName, hidden = false, units = units})
    else
        mist.dynAdd({country = "RUSSIA", category = "GROUND_UNIT", name = groupName, hidden = false, units = units})
    end

    -- message the unit spawning
    trigger.action.outText("An enemy unit of type " .. unitType .. " has been spawned", 5)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Cargo spawn command
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Spawn a specific cargo at a specific spot
function veafSpawn.spawnCargo(spawnSpot, cargoType, cargoSmoke)
    veafSpawn.logDebug("spawnCargo(cargoType = " .. cargoType ..")")
    veafSpawn.logDebug(string.format("spawnCargo: spawnSpot  x=%.1f y=%.1f, z=%.1f", spawnSpot.x, spawnSpot.y, spawnSpot.z))

    local units = {}
    veafSpawn.spawnedUnitsCounter = veafSpawn.spawnedUnitsCounter + 1
    local unitName = "VEAF Spawned Cargo #" .. veafSpawn.spawnedUnitsCounter

    local spawnPosition = veaf.findPointInZone(spawnSpot, 50, false)

    -- check spawned position validity
    if spawnPosition == nil then
        veafSpawn.logInfo("cannot find a suitable position for spawning cargo "..cargoType)
        trigger.action.outText("cannot find a suitable position for spawning cargo "..cargoType, 5)
        return
    end

    veafSpawn.logDebug(string.format("spawnCargo: spawnPosition  x=%.1f y=%.1f", spawnPosition.x, spawnPosition.y))
  
    -- compute cargo weight
    local cargoWeight = 0
    if cargoType == 'ammo_cargo' then
        cargoWeight = math.random(2205, 3000)
    elseif cargoType == 'barrels_cargo' then
        cargoWeight = math.random(300, 1058)
    elseif cargoType == 'container_cargo' then
        cargoWeight = math.random(300, 3000)
    elseif cargoType == 'f_bar_cargo' then
        cargoWeight = 0
    elseif cargoType == 'fueltank_cargo' then
        cargoWeight = math.random(1764, 3000)
    elseif cargoType == 'm117_cargo' then
        cargoWeight = 0
    elseif cargoType == 'oiltank_cargo' then
        cargoWeight = math.random(1543, 3000)
    elseif cargoType == 'uh1h_cargo' then
        cargoWeight = math.random(220, 3000)
    end
    
    -- create the cargo
    local cargoTable = {
		type = cargoType,
		country = 'USA',
		category = 'Cargos',
		name = unitName,
		x = spawnPosition.x,
		y = spawnPosition.y,
        canCargo = true,
        mass = cargoWeight
	}
	
	mist.dynAddStatic(cargoTable)
    
    -- smoke the cargo if needed
    if cargoSmoke then 
        local smokePosition={x=spawnPosition.x + mist.random(10,20), y=0, z=spawnPosition.y + mist.random(10,20)}
        local height = veaf.getLandHeight(smokePosition)
        smokePosition.y = height
        veafSpawn.logDebug(string.format("spawnCargo: smokePosition  x=%.1f y=%.1f z=%.1f", smokePosition.x, smokePosition.y, smokePosition.z))
        veafSpawn.spawnSmoke(smokePosition, trigger.smokeColor.Green)
        for i = 1, 10 do
            veafSpawn.logDebug("Signal flare 1 at " .. timer.getTime() + i*7)
            mist.scheduleFunction(veafSpawn.spawnSignalFlare, {smokePosition,trigger.flareColor.Red, mist.random(359)}, timer.getTime() + i*3)
        end
    end

    -- message the unit spawning
    local message = "A cargo of type " .. cargoType .. " weighting " .. cargoWeight .. " kg has been spawned"
    if cargoSmoke then 
        message = message .. ". It's marked with green smoke and red flares"
    end
    trigger.action.outText(message, 5)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Smoke and Flare commands
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- add a smoke marker over the marker area
function veafSpawn.spawnSmoke(spawnSpot, color)
    veafSpawn.logDebug("spawnSmoke(color = " .. color ..")")
    veafSpawn.logDebug(string.format("spawnSmoke: spawnSpot  x=%.1f y=%.1f, z=%.1f", spawnSpot.x, spawnSpot.y, spawnSpot.z))
	trigger.action.smoke(spawnSpot, color)
end

--- add a signal flare over the marker area
function veafSpawn.spawnSignalFlare(spawnSpot, color, azimuth)
    veafSpawn.logDebug("spawnSignalFlare(color = " .. color ..")")
    veafSpawn.logDebug(string.format("spawnSignalFlare: spawnSpot  x=%.1f y=%.1f, z=%.1f", spawnSpot.x, spawnSpot.y, spawnSpot.z))
	trigger.action.signalFlare(spawnSpot, color, azimuth)
end

--- add an illumination flare over the target area
function veafSpawn.spawnIlluminationFlare(spawnSpot, height)
    if height == nil then height = veafSpawn.IlluminationFlareAglAltitude end
    veafSpawn.logDebug("spawnIlluminationFlare(height = " .. height ..")")
    veafSpawn.logDebug(string.format("spawnIlluminationFlare: spawnSpot  x=%.1f y=%.1f, z=%.1f", spawnSpot.x, spawnSpot.y, spawnSpot.z))
    local vec3 = {x = spawnSpot.x, y = veaf.getLandHeight(spawnSpot) + height, z = spawnSpot.z}
	trigger.action.illuminationBomb(vec3)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu and help
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Build the initial radio menu
function veafSpawn.buildRadioMenu()
    veafSpawn.rootPath = missionCommands.addSubMenu(veafSpawn.RadioMenuName, veaf.radioMenuPath)
    missionCommands.addCommand("HELP", veafSpawn.rootPath, veafSpawn.help)
end

function veafSpawn.help()
    local text = 
        'Create a marker and type "veaf spawn <unit|smoke|flare> " in the text\n' ..
        'This will spawn the requested object in the DCS world\n' ..
        'You can add options (comma separated) :\n' ..
        '"veaf spawn unit" spawns a target vehicle/ship\n' ..
        '   "type [unit type]" spawns a specific unit ; types can be any DCS type\n' ..
        '"veaf spawn cargo" creates a cargo mission\n' ..
        '   "type [cargo type]" spawns a specific cargo ; types can be any of [ammo, barrels, container, fbar, fueltank, m117, oiltank, uh1h]\n' ..
        '   "smoke adds a smoke marker\n' ..
        '"veaf spawn smoke" spawns a smoke on the ground\n' ..
        '   "color [red|green|blue|white|orange]" specifies the smoke color\n' ..
        '"veaf spawn flare" lights things up with a flare\n' ..
        '   "alt <altitude in meters agl>" specifies the initial altitude'
            
    trigger.action.outText(text, 30)
end




-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafSpawn.initialize()
    veafSpawn.buildRadioMenu()
    veafMarkers.registerEventHandler(veafMarkers.MarkerChange, veafSpawn.onEventMarkChange)
end

veafSpawn.logInfo(string.format("Loading version %s", veafSpawn.Version))


