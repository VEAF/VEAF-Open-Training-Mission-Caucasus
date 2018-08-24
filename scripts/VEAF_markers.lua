-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF Markers Parser for DCS World
-- Version 0.3
-- By zip (2018)
--
-- Features:
-- ---------
-- * Listen to marker change events and execute commands, with optional parameters
-- * Possibilities : 
-- *    - create a CAS target group, protected by SAM, AAA and manpads, to use for CAS training
-- *    - spawn a smoke marker
-- *    - light up a zone by dropping a flare
-- *    - spawn a specific ennemy unit
-- *    - create a cargo drop to be picked by a helo
-- * Works with all current and future maps (Caucasus, NTTR, Normandy, PG, ...)
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
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
--     * OPEN --> Browse to the location where you saved the script and click OK.
-- 4.) Save the mission and start it.
-- 5.) Have fun :)
--
-- Basic Usage:
-- ------------
-- 1.) Place a mark on the F10 map.
-- 2.) As text enter "veaf do <command>" ; the command can be any of [cas, smoke, flare, spawn, cargo]
-- 3.) Click somewhere else on the map to submit the new text.
-- 4.) The command will be processed. A message will appear to confirm this
-- 5.) The original mark will disappear.
--
-- Options:
-- --------
-- Type "veaf do cas" to create a default CAS target group
--      add ", defense 0" to completely disable air defenses
--      add ", defense [1-5]" to specify air defense cover (1 = light, 5 = heavy)
--      add ", size [1-5]" to change the group size (1 = small, 5 = huge)
--      add ", armor [1-5]" to specify armor presence (1 = light, 5 = heavy)
--      add ", spacing [1-5]" to change the groups spacing (1 = dense, 3 = default, 5 = sparse)
-- Type "veaf do smoke" to create a smoke marker 
--      add ", color [red|green|blue|white|orange]" to specify the smoke color
-- Type "veaf do flare" to illuminate a zone with a flare
-- Type "veaf do spawn, type [unit type]" to spawn a specific unit ; types can be any DCS type (replace spaces with the pound character '#'')
-- Type "veaf do cargo, type [cargo type]" to spawn a specific cargo ; types can be any of [ammo, barrels, container, fbar, fueltank, m117, oiltank, uh1h]
--      add ", smoke [red|green|blue|white|orange]" to add a smoke of the specific color
--
-- *** NOTE ***
-- * All keywords are CaSE inSenSITvE.
-- * Commas are the separators between options ==> They are IMPORTANT!
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- veafCas Table.
veafCas = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafCas.id = "VEAF "

--- Version.
veafCas.version = "0.3.1"

--- Key phrase to look for in the mark text which triggers the weather report.
veafCas.keyphrase = "veaf do "

--- DCS bug regarding wrong marker vector components was fixed. If so, set to true!
veafCas.DCSbugfixed = false

--- Enable logDebug mode ==> give more output to DCS log file.
veafCas.Debug = true
veafCas.Trace = false

--- Number of seconds between each check of the CAS group watchdog function
veafCas.SecondsBetweenWatchdogChecks = 15

--- Number of seconds between each smoke request on the CAS targets group
veafCas.SecondsBetweenSmokeRequests = 180

--- Number of seconds between each flare request on the CAS targets group
veafCas.SecondsBetweenFlareRequests = 120

--- Name of the CAS targets vehicles group 
veafCas.RedCasVehiclesGroupName = "Red CAS Group Vehicles"

--- Name of the CAS targets infantry group 
veafCas.RedCasInfantryGroupName = "Red CAS Group Infantry"

--- Name of the spawned units group 
veafCas.RedSpawnedUnitsGroupName = "VEAF Spawned Units"

veafCas.INFO_TEXT = 'INFO - Request a CAS task by creating a marker and setting its text to "veaf cas create"'

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Radio menus paths
veafCas._targetMarkersPath = nil
veafCas._targetInfoPath = nil

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

-- CAS Group watchdog function id
veafCas.groupAliveCheckTaskID = 'none'

-- Smoke reset function id
veafCas.smokeResetTaskID = 'none'    

-- Flare reset function id
veafCas.flareResetTaskID = 'none'    
    
-- radio menus
veafCas._taskingsRootPath = 'none'
veafCas._taskingsGroundPath = 'none'

-- counts the units generated by the Spawn command
veafCas.spawnedUnitsCounter = 0

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafCas.logInfo(message)
    env.info(veafCas.id .. message)
end

function veafCas.logDebug(message)
    if veafCas.Debug then
        env.info(veafCas.id .. message)
    end
end

function veafCas.logTrace(message)
    if veafCas.Trace then
        env.info(veafCas.id .. message)
    end
end

--- Return the height of the land at the coordinate.
function veafCas.getLandHeight(vec3)
    veafCas.logDebug(string.format("getLandHeight: vec3  x=%.1f y=%.1f, z=%.1f", vec3.x, vec3.y, vec3.z))
    local vec2 = {x = vec3.x, y = vec3.z}
    veafCas.logDebug(string.format("getLandHeight: vec2  x=%.1f z=%.1f", vec3.x, vec3.z))
    -- We add 1 m "safety margin" because data from getlandheight gives the surface and wind at or below the surface is zero!
    local height = math.floor(land.getHeight(vec2) + 1)
    veafCas.logDebug(string.format("getLandHeight: result  height=%.1f",height))
    return height
end

--- Return a point at the same coordinates, but on the surface
function veafCas.placePointOnLand(vec3)
    veafCas.logDebug(string.format("getLandHeight: vec3  x=%.1f y=%.1f, z=%.1f", vec3.x, vec3.y, vec3.z))
    local height = veafCas.getLandHeight(vec3)
    veafCas.logDebug(string.format("getLandHeight: result  height=%.1f",height))
    local result={x=vec3.x, y=height, z=vec3.z}
    veafCas.logDebug(string.format("placePointOnLand: result  x=%.1f y=%.1f, z=%.1f", result.x, result.y, result.z))
    return result
end

--- Split string. C.f. http://stackoverflow.com/questions/1426954/split-string-in-lua
function veafCas.split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

--- Get the average center of a group position (average point of all units position)
function veafCas.getAveragePosition(groupName)
	local count

	local totalPosition = {x = 0,y = 0,z = 0}
	local group = Group.getByName(groupName)
	if group then
		local units = Group.getUnits(group)
		for count = 1,#units do
			if units[count] then 
				totalPosition = mist.vec.add(totalPosition,Unit.getPosition(units[count]).p)
			end
		end
		if #units > 0 then
			return mist.vec.scalar_mult(totalPosition,1/#units)
		else
			return nil
		end
	else
		return nil
	end
end

function veafCas.emptyFunction()
end

--- Returns the wind direction (from) and strength.
function veafCas.getWind(point)

    -- Get wind velocity vector.
    local windvec3  = atmosphere.getWind(point)
    local direction = math.floor(math.deg(math.atan2(windvec3.z, windvec3.x)))
    
    if direction < 0 then
      direction = direction + 360
    end
    
    -- Convert TO direction to FROM direction. 
    if direction > 180 then
      direction = direction-180
    else
      direction = direction+180
    end
    
    -- Calc 2D strength.
    local strength=math.floor(math.sqrt((windvec3.x)^2+(windvec3.z)^2))
    
    -- Debug output.
    veafCas.logDebug(string.format("Wind data: point x=%.1f y=%.1f, z=%.1f", point.x, point.y,point.z))
    veafCas.logDebug(string.format("Wind data: wind  x=%.1f y=%.1f, z=%.1f", windvec3.x, windvec3.y,windvec3.z))
    veafCas.logDebug(string.format("Wind data: |v| = %.1f", strength))
    veafCas.logDebug(string.format("Wind data: ang = %.1f", direction))
    
    -- Return wind direction and strength km/h.
    return direction, strength, windvec3
  end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event handler.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Event handler.
veafCas.eventHandler = {}

--- Handle world events.
function veafCas.eventHandler:onEvent(Event)
    -- Only interested in S_EVENT_MARK_*
    if Event == nil or Event.idx == nil then
        return true
    end

    -- Debug output.
    if Event.id == world.event.S_EVENT_MARK_ADDED then
        veafCas.logDebug("S_EVENT_MARK_ADDED")
    elseif Event.id == world.event.S_EVENT_MARK_CHANGE then
        veafCas.logDebug("S_EVENT_MARK_CHANGE")
    elseif Event.id == world.event.S_EVENT_MARK_REMOVED then
        veafCas.logDebug("S_EVENT_MARK_REMOVED")
    end
    veafCas.logTrace(string.format("Event id        = %s", tostring(Event.id)))
    veafCas.logTrace(string.format("Event time      = %s", tostring(Event.time)))
    veafCas.logTrace(string.format("Event idx       = %s", tostring(Event.idx)))
    veafCas.logTrace(string.format("Event coalition = %s", tostring(Event.coalition)))
    veafCas.logTrace(string.format("Event group id  = %s", tostring(Event.groupID)))
    veafCas.logTrace(string.format("Event pos X     = %s", tostring(Event.pos.x)))
    veafCas.logTrace(string.format("Event pos Y     = %s", tostring(Event.pos.y)))
    veafCas.logTrace(string.format("Event pos Z     = %s", tostring(Event.pos.z)))
    if Event.initiator ~= nil then
        local _unitname = Event.initiator:getName()
        veafCas.logTrace(string.format("Event ini unit  = %s", tostring(_unitname)))
    end
    veafCas.logTrace(string.format("Event text      = \n%s", tostring(Event.text)))

    -- Call event function when a marker has changed, i.e. text was entered or changed.
    if Event.id == world.event.S_EVENT_MARK_CHANGE then
        veafCas._OnEventMarkChange(Event)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event handler functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Function executed when a mark has changed. This happens when text is entered or changed.
function veafCas._OnEventMarkChange(Event)
    -- Check if marker has a text and the veafCas.keyphrase keyphrase.
    if Event.text ~= nil and Event.text:lower():find(veafCas.keyphrase) then
        -- Convert (wrong x-->z, z-->x) vec3
        local vec3
        if veafCas.DCSbugfixed then
            vec3 = {x = Event.pos.x, y = Event.pos.y, z = Event.pos.z}
        else
            vec3 = {x = Event.pos.z, y = Event.pos.y, z = Event.pos.x}
        end

        -- By default, alt of mark point is always 5 m! Adjust for the correct ASL height.
        vec3.y = veafCas.getLandHeight(vec3)

        -- Analyse the mark point text and extract the keywords.
        local _options = veafCas.markTextAnalysis(Event.text)

        if _options then
            -- Check options commands
            if _options.create then
                -- create the group
                veafCas.generateCasMission(vec3, _options.size, _options.defense, _options.armor, _options.spacing, _options.disperseOnAttack, "Random")

            elseif _options.smoke then
                veafCas.generateSmoke(vec3, _options.smokeColor)
            elseif _options.flare then
                veafCas.generateIlluminationFlare(vec3)
            elseif _options.spawn then
                veafCas.spawnUnit(vec3, _options.unitType)
            elseif _options.cargo then
                veafCas.spawnCargo(vec3, _options.cargoType, _options.cargoSmoke)
            end
        else
            -- None of the keywords matched.
            return
        end

        -- Delete old mark.
        veafCas.logDebug(string.format("Removing mark # %d.", Event.idx))
        trigger.action.removeMark(Event.idx)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Analyse the mark text and extract keywords.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Extract keywords from mark text.
function veafCas.markTextAnalysis(text)
    veafCas.logDebug(string.format("MarkTextAnalysis text:\n%s", text))

    -- Option parameters extracted from the mark text.
    local switch = {}
    switch.create = false
    switch.smoke = false
    switch.flare = false
    switch.spawn = false
    switch.cargo = false

    -- size ; ranges from 1 to 5, 5 being the biggest.
    switch.size = 1

    -- defenses force ; ranges from 1 to 5, 5 being the toughest.
    switch.defense = 1

    -- armor force ; ranges from 1 to 5, 5 being the strongest and most modern.
    switch.armor = 1

    -- spacing ; ranges from 1 to 5, 3 being the default and 5 being the widest spacing.
    switch.spacing = 3

    -- disperse on attack ; self explanatory, if keyword is present the option will be set to true
    switch.disperseOnAttack = false

    -- spawned unit type
    switch.unitType = "BTR-80"

    -- smoke color
    switch.smokeColor = trigger.smokeColor.Red

    -- optional cargo smoke
    switch.cargoSmoke = false

    -- cargo type
    switch.cargoType = "uh1h_cargo"

    -- Check for correct keywords.
    if text:lower():find(veafCas.keyphrase .. "cas") then
        switch.create = true
    elseif text:lower():find(veafCas.keyphrase .. "smoke") then
        switch.smoke = true
    elseif text:lower():find(veafCas.keyphrase .. "flare") then
        switch.flare = true
    elseif text:lower():find(veafCas.keyphrase .. "spawn") then
        switch.spawn = true
    elseif text:lower():find(veafCas.keyphrase .. "cargo") then
        switch.cargo = true
    else
        return nil
    end

    -- keywords are split by ","
    local keywords = veafCas.split(text, ",")

    for _, keyphrase in pairs(keywords) do
        -- Split keyphrase by space. First one is the key and second, ... the parameter(s) until the next comma.
        local str = veafCas.split(keyphrase, " ")
        local key = str[1]
        local val = str[2]

        if switch.create and key:lower() == "size" then
            -- Set size.
            veafCas.logDebug(string.format("Keyword size = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 1 then
                switch.size = nVal
            end
        end

        if switch.create and key:lower() == "defense" then
            -- Set defense.
            veafCas.logDebug(string.format("Keyword defense = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 0 then
                switch.defense = nVal
            end
        end

        if switch.create and key:lower() == "armor" then
            -- Set armor.
            veafCas.logDebug(string.format("Keyword armor = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 0 then
                switch.armor = nVal
            end
        end

        if switch.create and key:lower() == "spacing" then
            -- Set spacing.
            veafCas.logDebug(string.format("Keyword spacing = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 1 then
                switch.spacing = nVal
            end
        end

        if switch.create and key:lower() == "disperse" then
            -- Set disperse on attack.
            veafCas.logDebug("Keyword disperse is set")
            switch.disperseOnAttack = true
        end

        if switch.spawn and key:lower() == "type" then
            -- Set unit type.
            veafCas.logDebug(string.format("Keyword type = %s", val))
            switch.unitType = string.gsub(val, "#", " ") -- replace #s with the original spaces
        end

        if switch.smoke and key:lower() == "color" then
            -- Set smoke color.
            veafCas.logDebug(string.format("Keyword color = %s", val))
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

        if switch.cargo and key:lower() == "type" then
            -- Set cargo type.
            veafCas.logDebug(string.format("Keyword type = %s", val))
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
            veafCas.logDebug("Keyword smoke is set")
            switch.cargoSmoke = true
        end
    end

    return switch
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CAS target group generation and management
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Find a suitable point for spawning a unit in a <dispersion>-sized circle around a spot
function veafCas.findPointInZone(spawnSpot, dispersion, isShip)
    local unitPosition
    local tryCounter = 1000
    
    repeat -- Place the unit in a "dispersion" ft radius circle from the spawn spot
        unitPosition = mist.getRandPointInCircle(spawnSpot, dispersion)
        local landType = land.getSurfaceType(unitPosition)
        tryCounter = tryCounter - 1
    until ((isShip and landType == land.SurfaceType.WATER) or (not(isShip) and (landType == land.SurfaceType.LAND or landType == land.SurfaceType.ROAD or landType == land.SurfaceType.RUNWAY))) or tryCounter == 0
    if tryCounter == 0 then
        return nil
    else
        return unitPosition
    end
end

--- Add a unit to the <group> on a suitable point in a <dispersion>-sized circle around a spot
function veafCas.addUnit(group, spawnSpot, dispersion, unitType, unitName, skill)
    local unitPosition = veafCas.findPointInZone(spawnSpot, dispersion, false)
    if unitPosition ~= nil then
        table.insert(
            group,
            {
                ["x"] = unitPosition.x,
                ["y"] = unitPosition.y,
                ["type"] = unitType,
                ["name"] = unitName,
                ["heading"] = 0,
                ["skill"] = skill
            }
        )
    else
        veafCas.logInfo("cannot find a suitable position for unit "..unitType)
    end
end

--- Generates an air defense group
function veafCas.generateAirDefenseGroup(groupId, spawnSpot, defense, armor, skill)
    local infantryGroup = {}
    local vehiclesGroup = {}

    -- generate a primary air defense platoon
    local groupCount = mist.random(2, 4)
    local dispersion = (groupCount+1) * 10 + 25
    local samType
    local samTypeRand 
    for i = 1, 1 do
        samTypeRand = mist.random(100)
				
        if samTypeRand > (90-(3*(defense-1))) then
            samType = 'Tor 9A331'
        elseif samTypeRand > (75-(4*(defense-1))) then
            samType = 'Osa 9A33 ln'
        elseif samTypeRand > (60-(4*(defense-1))) then
            samType = '2S6 Tunguska'
        elseif samTypeRand > (40-(5*(defense-1))) then
            samType = 'Strela-10M3'
        else
            samType = 'Strela-1 9P31'
        end
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, samType, veafCas.RedCasVehiclesGroupName .. " Air Defense Group #" .. groupId .. " vehicle #" .. i, skill)
    end

    -- generate a secondary air defense platoon
    local groupCount = mist.random(1, 3)
    for i = 2, groupCount do
        samTypeRand = mist.random(100)
				
        if samTypeRand > (75-(4*(defense-1))) then
            samType = '2S6 Tunguska'
        elseif samTypeRand > (65-(5*(defense-1))) then
            samType = 'Strela-10M3'
        elseif samTypeRand > (50-(5*(defense-1))) then
            samType = 'Strela-1 9P31'
        elseif samTypeRand > (30-(5*(defense-1))) then
            samType = 'ZSU-23-4 Shilka'
        else
            samType = 'Ural-375 ZU-23'
        end
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, samType, veafCas.RedCasVehiclesGroupName .. " Air Defense Group #" .. groupId .. " vehicle #" .. i, skill)
    end

    return vehiclesGroup, infantryGroup
end

--- Generates a transport company and its air defenses
function veafCas.generateTransportCompany(groupId, spawnSpot, defense, armor, skill)
    local infantryGroup = {}
    local vehiclesGroup = {}

    -- generate a transport company
    local groupCount = mist.random(2, 5)
    local dispersion = (groupCount+1) * 10 + 25
    local transportType
    local transportRand
  
    for i = 1, groupCount do
        transportRand = mist.random(8)
        if transportRand == 1 then
            transportType = 'ATMZ-5'
        elseif transportRand == 2 then
            transportType = 'Ural-4320 APA-5D'            
        elseif transportRand == 3 then
            transportType = 'SKP-11'
        elseif transportRand == 4 then
            transportType = 'GAZ-66'
        elseif transportRand == 5 then
            transportType = 'KAMAZ Truck'
        elseif transportRand == 6 then
            transportType = 'Ural-375'
        elseif transportRand == 7 then
            transportType = 'Ural-4320T'
        elseif transportRand == 8 then
            transportType = 'ZIL-131 KUNG'
        end
        veafCas.logDebug("transportType = " .. transportType)
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, transportType, veafCas.RedCasVehiclesGroupName .. " Transport Company #" .. groupId .. " vehicle #" .. i, skill)
    end

    -- add an air defense vehicle
    if defense > 2 then 
        -- defense = 3-5 : add a Shilka
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, "ZSU-23-4 Shilka", veafCas.RedCasVehiclesGroupName .. " Transport Company #" .. groupId .. " Air Defense Unit", skill)
    elseif defense > 0 then
        -- defense = 1 : add a ZU23 on a truck
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, "Ural-375 ZU-23", veafCas.RedCasVehiclesGroupName .. " Transport Company #" .. groupId .. " Air Defense Unit", skill)
    end

    return vehiclesGroup, infantryGroup
end

--- Generates an armor platoon and its air defenses
function veafCas.generateArmorPlatoon(groupId, spawnSpot, defense, armor, skill)
    local infantryGroup = {}
    local vehiclesGroup = {}

    -- generate an armor platoon
    local groupCount = mist.random(3, 6)
    local dispersion = (groupCount+1) * 10 + 25
    local armorType
    local armorRand
    for i = 1, groupCount do
        if armor <= 2 then
            armorRand = mist.random(3)
            if armorRand == 1 then
                armorType = 'BRDM-2'
            elseif armorRand == 2 then
                armorType = 'BMD-1'
            elseif armorRand == 3 then
                armorType = 'BMP-1'
            end
        elseif armor == 3 then
            armorRand = mist.random(3)
            if armorRand == 1 then
                armorType = 'BMP-1'
            elseif armorRand == 2 then
                armorType = 'BMP-2'
            elseif armorRand == 3 then
                armorType = 'T-55'
            end
        elseif armor == 4 then
            armorRand = mist.random(4)
            if armorRand == 1 then
                armorType = 'BMP-1'
            elseif armorRand == 2 then
                armorType = 'BMP-2'
            elseif armorRand == 3 then
                armorType = 'T-55'
            elseif armorRand == 4 then
                armorType = 'T-72B'
            end
        elseif armor >= 5 then
            armorRand = mist.random(4)
            if armorRand == 1 then
                armorType = 'BMP-2'
            elseif armorRand == 2 then
                armorType = 'BMP-3'
            elseif armorRand == 4 then
                armorType = 'T-80UD'
            elseif armorRand == 5 then
                armorType = 'T-90'
            end
        end        
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, armorType, veafCas.RedCasVehiclesGroupName .. " Armor Platoon #" .. groupId .. " unit #" .. i, skill)
    end

    -- add an air defense vehicle
    if defense > 3 then 
        -- defense = 4-5 : add a Tunguska
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, "2S6 Tunguska", veafCas.RedCasVehiclesGroupName .. " Armor Platoon #" .. groupId .. " Air Defense Unit", skill)
    elseif defense > 0 then
        -- defense = 1-3 : add a Shilka
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, "ZSU-23-4 Shilka", veafCas.RedCasVehiclesGroupName .. " Armor Platoon #" .. groupId .. " Air Defense Unit", skill)
    end

    return vehiclesGroup, infantryGroup
end

--- Generates an infantry group along with its manpad units and tranport vehicles
function veafCas.generateInfantryGroup(groupId, spawnSpot, defense, armor, skill)
    local infantryGroup = {}
    local vehiclesGroup = {}

    -- generate an infantry group
    local groupCount = mist.random(3, 7)
    local dispersion = (groupCount+1) * 5 + 25
    for i = 1, groupCount do
        veafCas.addUnit(infantryGroup, spawnSpot, dispersion, "Soldier AK", veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " unit #" .. i, skill)
    end

    -- add a transport vehicle
    if armor > 0 then
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, "BTR-80", veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " APC", skill)
    else
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, "GAZ-3308", veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " truck", skill) -- TODO check if tranport type is correct
    end

    -- add manpads if needed
    if defense > 3 then
        -- for defense = 4-5, spawn a full Igla-S team
        veafCas.addUnit(infantryGroup, spawnSpot, dispersion, "SA-18 Igla-S comm", veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad COMM soldier", skill)
        veafCas.addUnit(infantryGroup, spawnSpot, dispersion, "SA-18 Igla-S manpad", veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad launcher soldier", skill)
    elseif defense > 0 then
        -- for defense = 1-3, spawn a single Igla soldier
        veafCas.addUnit(infantryGroup, spawnSpot, dispersion, "SA-18 Igla manpad", veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad launcher soldier", skill)
    else
        -- for defense = 0, don't spawn any manpad
    end

    return vehiclesGroup, infantryGroup
end

--- Generates a complete CAS target group
function veafCas.generateCasMission(spawnSpot, size, defense, armor, spacing, skill, disperseOnAttack)
    local infantryUnits = {}
    local vehiclesUnits = {}
    local groupId = 1234
    local zoneRadius = (size+spacing-2)*400

    if veafCas.groupAliveCheckTaskID ~= 'none' then
        trigger.action.outText("A CAS target group already exists !", 5)
        return 
    end


    -- Move reaper
    -- TODO

    -- generate between size-2 and size+1 infantry groups
    local infantryGroupsCount = mist.random(math.max(1, size-2), size + 1)
    veafCas.logDebug("infantryGroupsCount = " .. infantryGroupsCount)
    for i = 1, infantryGroupsCount do
        local groupPosition = veafCas.findPointInZone(spawnSpot, zoneRadius, false)
        if groupPosition ~= nil then
            local vehiclesGroup, infantryGroup = veafCas.generateInfantryGroup(groupId, groupPosition, defense, armor, skill)
            -- add the units to the global units list
            for _,u in pairs(vehiclesGroup) do
                table.insert(vehiclesUnits, u)
            end
            for _,u in pairs(infantryGroup) do
                table.insert(infantryUnits, u)
            end
        else
            veafCas.logInfo("cannot find a suitable position for group "..groupId)
        end
        groupId = groupId + 1
    end

    if armor > 0 then
        -- generate between size-2 and size+1 armor platoons
        local armorPlatoonsCount = mist.random(math.max(1, size-2), size + 1)
        veafCas.logDebug("armorPlatoonsCount = " .. armorPlatoonsCount)
        for i = 1, armorPlatoonsCount do
            local groupPosition = veafCas.findPointInZone(spawnSpot, zoneRadius, false)
            if groupPosition ~= nil then
                local group = veafCas.generateArmorPlatoon(groupId, groupPosition, defense, armor, skill)
                -- add the units to the global units list
                for _,u in pairs(group) do
                    table.insert(vehiclesUnits, u)
                end
            else
                veafCas.logInfo("cannot find a suitable position for group "..groupId)
            end
            groupId = groupId + 1
        end
    end

    if defense > 0 then
        -- generate between 1 and 2 air defense groups
        local airDefenseGroupsCount = 1
        if defense > 3 then
            airDefenseGroupsCount = 2
        end
        veafCas.logDebug("airDefenseGroupsCount = " .. airDefenseGroupsCount)
        for i = 1, airDefenseGroupsCount do
            local groupPosition = veafCas.findPointInZone(spawnSpot, zoneRadius, false)
            if groupPosition ~= nil then
                local group = veafCas.generateAirDefenseGroup(groupId, groupPosition, defense, armor, skill)
                -- add the units to the global units list
                for _,u in pairs(group) do
                    table.insert(vehiclesUnits, u)
                end
            else
                veafCas.logInfo("cannot find a suitable position for group "..groupId)
            end
            groupId = groupId + 1
        end
    end

    -- generate between 1 and size transport companies
    local transportCompaniesCount = mist.random(1, size)
    veafCas.logDebug("transportCompaniesCount = " .. transportCompaniesCount)
    for i = 1, transportCompaniesCount do
        local groupPosition = veafCas.findPointInZone(spawnSpot, zoneRadius, false)
        if groupPosition ~= nil then
            local group = veafCas.generateTransportCompany(groupId, groupPosition, defense, armor, skill)
            -- add the units to the global units list
            for _,u in pairs(group) do
                table.insert(vehiclesUnits, u)
            end
        else
            veafCas.logInfo("cannot find a suitable position for group "..groupId)
        end
        groupId = groupId + 1
    end

    -- actually spawn groups
    mist.dynAdd({country = "RUSSIA", category = "GROUND_UNIT", name = veafCas.RedCasVehiclesGroupName, hidden = false, units = vehiclesUnits})
    mist.dynAdd({country = "RUSSIA", category = "GROUND_UNIT", name = veafCas.RedCasInfantryGroupName, hidden = false, units = infantryUnits})

    -- set AI options for vehicles
    local controller = Group.getByName(veafCas.RedCasVehiclesGroupName):getController()
    controller:setOption(9, 2) -- set alarm state to red
    controller:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, disperseOnAttack) -- set disperse on attack according to the option

    -- set AI options for infantry
    controller = Group.getByName(veafCas.RedCasInfantryGroupName):getController()
    controller:setOption(9, 2) -- set alarm state to red
    controller:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, disperseOnAttack) -- set disperse on attack according to the option

    -- generate information dispatch
    local averageGroupPosition = veafCas.getAveragePosition(veafCas.RedCasVehiclesGroupName)
    local lat, lon = coord.LOtoLL(averageGroupPosition)
    local llString = mist.tostringLL(lat, lon, 2)
    local mgrsString = mist.tostringMGRS(coord.LLtoMGRS(lat, lon), 3)

    -- get position from bullseye
    local bullseye = mist.utils.makeVec3(mist.DBs.missionData.bullseye.blue, 0)
	local vec = {x = averageGroupPosition.x - bullseye.x, y = averageGroupPosition.y - bullseye.y, z = averageGroupPosition.z - bullseye.z}
	local dir = mist.utils.round(mist.utils.toDegree(mist.utils.getDir(vec, bullseye)), 0)
	local dist = mist.utils.get2DDist(averageGroupPosition, bullseye)
	local distMetric = mist.utils.round(dist/1000, 0)
	local distImperial = mist.utils.round(mist.utils.metersToNM(dist), 0)
	local fromBullseye = string.format('%03d', dir) .. ' for ' .. distMetric .. 'km/' .. distImperial .. 'nm'

    -- get wind information
    local windDirection, windStrength = veafCas.getWind(veafCas.placePointOnLand(averageGroupPosition))

    -- add radio menu information messages
    veafCas._targetInfoPath = missionCommands.addSubMenu("Target information", veafCas._taskingsGroundPath)
    missionCommands.addCommand("TARGET: Group of " .. #vehiclesUnits .. " vehicles and " .. #infantryUnits .. " soldiers.", veafCas._targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand("LAT LON: " .. llString .. ".", veafCas._targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand("MGRS/UTM: " .. mgrsString .. ".", veafCas._targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand("FROM BULLSEYE: " .. fromBullseye .. ".", veafCas._targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand('TARGET ALT: ' .. veafCas.getLandHeight(spawnSpot) .. "m",  veafCas._targetInfoPath, veafCas.emptyFunction)
    local windText = "WIND: no wind"
    if windStrength > 0 then
        windText = string.format("WIND: from %s at %s m/s", windDirection, windStrength)
    end
    missionCommands.addCommand(windText, veafCas._targetInfoPath, veafCas.emptyFunction)
    
    -- add radio menu commands
    missionCommands.removeItem({'Tasking', 'Ground', veafCas.INFO_TEXT})
    missionCommands.addCommand('Skip current objective', veafCas._taskingsGroundPath, veafCas.skipCasTarget)
    veafCas._targetMarkersPath = missionCommands.addSubMenu("Target markers", veafCas._taskingsGroundPath)
    missionCommands.addCommand('Request smoke on target area', veafCas._targetMarkersPath, veafCas.smokeCasTargetGroup)
    missionCommands.addCommand('Request illumination flare over target area', veafCas._targetMarkersPath, veafCas.flareCasTargetGroup)

    trigger.action.outText("An enemy group of " .. #vehiclesUnits .. " vehicles and " .. #infantryUnits .. " soldiers has been located. Consult your F10 radio commands for more information.", 5)

    -- start checking for targets destruction
    veafCas.casGroupWatchdog()
end

--- add a smoke marker over the target area
function veafCas.smokeCasTargetGroup()
    veafCas.generateSmoke(veafCas.getAveragePosition(veafCas.RedCasVehiclesGroupName), trigger.smokeColor.Red)
	trigger.action.outText('Copy smoke requested, RED smoke on the deck!',5)
	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers', 'Request smoke on target area'})
    missionCommands.addCommand('Target is marked with red smoke', veafCas._targetMarkersPath, veafCas.emptyFunction)
    veafCas.smokeResetTaskID = mist.scheduleFunction(veafCas.smokeReset,{},timer.getTime()+veafCas.SecondsBetweenSmokeRequests)
end

--- Reset the smoke request radio menu
function veafCas.smokeReset()
	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers', 'Target is marked with red smoke'})
	missionCommands.addCommand('Request smoke on target area', veafCas._targetMarkersPath, veafCas.smokeCasTargetGroup)
	trigger.action.outText('Smoke marker available',5)
end

--- add an illumination flare over the target area
function veafCas.flareCasTargetGroup()
    veafCas.generateIlluminationFlare(veafCas.getAveragePosition(veafCas.RedCasVehiclesGroupName))
	trigger.action.outText('Copy illumination flare requested, illumination flare over target area!',5)
	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers', 'Request illumination flare over target area'})
	missionCommands.addCommand('Target area is marked with illumination flare', veafCas._targetMarkersPath, veafCas.emptyFunction)
    veafCas.flareResetTaskID = mist.scheduleFunction(veafCas.flareReset,{},timer.getTime()+veafCas.SecondsBetweenFlareRequests)
end

--- Reset the flare request radio menu
function veafCas.flareReset()
	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers', 'Target area is marked with illumination flare'})
    missionCommands.addCommand('Request illumination flare over target area', veafCas._targetMarkersPath, veafCas.flareCasTargetGroup)
	trigger.action.outText('Target illumination available',5)
end

--- Checks if the vehicles group is still alive, and if not announces the end of the CAS mission
function veafCas.casGroupWatchdog() 
    local group = Group.getByName(veafCas.RedCasVehiclesGroupName)
    if group and group:isExist() == true and #group:getUnits() > 0 then
        veafCas.groupAliveCheckTaskID = mist.scheduleFunction(veafCas.casGroupWatchdog,{},timer.getTime()+veafCas.SecondsBetweenWatchdogChecks)
    else
        trigger.action.outText("Objective group destroyed!", 5)
        veafCas.cleanupAfterMission()
    end
end

--- Called from the "Skip target" radio menu : remove the current CAS target group
function veafCas.skipCasTarget()
    trigger.action.outText("Skipping CAS objective group ; please stand by...", 5)
    veafCas.cleanupAfterMission()
    trigger.action.outText("CAS objective group cleaned up.", 5)
end

--- Cleanup after either mission is ended or aborted
function veafCas.cleanupAfterMission()
    -- destroy vehicles and infantry groups
    local group = Group.getByName(veafCas.RedCasVehiclesGroupName)
    if group and group:isExist() == true then
        group:destroy()
    end
    group = Group.getByName(veafCas.RedCasInfantryGroupName)
    if group and group:isExist() == true then
        group:destroy()
    end

    -- remove the watchdog function
    if veafCas.groupAliveCheckTaskID ~= 'none' then
        mist.removeFunction(veafCas.groupAliveCheckTaskID)
    end
    veafCas.groupAliveCheckTaskID = 'none'

    -- update the radio menu
    missionCommands.removeItem({'Tasking', 'Ground', 'Skip current CAS target'})
    missionCommands.removeItem({'Tasking', 'Ground', 'Target markers'})
    missionCommands.removeItem({'Tasking', 'Ground', 'Target information'})
    missionCommands.addCommand(veafCas.INFO_TEXT, veafCas._taskingsGroundPath, veafCas.emptyFunction)
end

--- Build the initial radio menu
function veafCas.buildRadioMenu()
    veafCas._taskingsRootPath = missionCommands.addSubMenu('Tasking')
    veafCas._taskingsGroundPath = missionCommands.addSubMenu('Ground', veafCas._taskingsRootPath)
    missionCommands.addCommand(veafCas.INFO_TEXT, veafCas._taskingsGroundPath, veafCas.emptyFunction)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Unit spawn command
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Spawn a specific unit at a specific spot
function veafCas.spawnUnit(spawnSpot, unitType)
    veafCas.logDebug("spawnUnit(unitType = " .. unitType .. ")")
    veafCas.logDebug(string.format("spawnUnit: spawnSpot  x=%.1f y=%.1f, z=%.1f", spawnSpot.x, spawnSpot.y, spawnSpot.z))
    
    veafCas.spawnedUnitsCounter = veafCas.spawnedUnitsCounter + 1

    local isShip = false
    local units = {}
    
    if unitType == "VINSON" or  unitType == "PERRY" or unitType == "TICONDEROG" or unitType == "ALBATROS" or unitType == "KUZNECOW" or unitType == "MOLNIYA" or unitType == "MOSCOW" or unitType == "NEUSTRASH" or unitType == "PIOTR" or unitType == "REZKY" or unitType == "ELNYA" or unitType == "Dry-cargo ship-2" or unitType == "Dry-cargo ship-1" or unitType == "ZWEZDNY" or unitType == "KILO" or unitType == "SOM" or unitType == "speedboat" then
        isShip = true
    end
    veafCas.logDebug("spawnUnit isShip = " .. tostring(isShip))
    
    local groupName = veafCas.RedSpawnedUnitsGroupName .. " " .. unitType .. " #" .. veafCas.spawnedUnitsCounter
    local unitName = groupName

    local spawnPosition = veafCas.findPointInZone(spawnSpot, 50, isShip)
    if spawnPosition == nil then
        if isShip then 
            veafCas.logInfo("cannot find a suitable position for spawning naval unit "..unitType)
            trigger.action.outText("cannot find a suitable position for spawning naval unit "..unitType, 5)
            return
        else
            veafCas.logInfo("cannot find a suitable position for spawning ground unit "..unitType)
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
function veafCas.spawnCargo(spawnSpot, cargoType, cargoSmoke)
    veafCas.logDebug("spawnCargo(cargoType = " .. cargoType ..")")
    veafCas.logDebug(string.format("spawnCargo: spawnSpot  x=%.1f y=%.1f, z=%.1f", spawnSpot.x, spawnSpot.y, spawnSpot.z))

    local units = {}
    local unitName = "VEAF Spawned Unit #" .. mist.random(90000,99999)

    local spawnPosition = veafCas.findPointInZone(spawnSpot, 50, false)

    -- check spawned position validity
    if spawnPosition == nil then
        veafCas.logInfo("cannot find a suitable position for spawning cargo "..cargoType)
        trigger.action.outText("cannot find a suitable position for spawning cargo "..cargoType, 5)
        return
    end

    veafCas.logDebug(string.format("spawnCargo: spawnPosition  x=%.1f y=%.1f", spawnPosition.x, spawnPosition.y))
  
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
		name = cargoType,
		x = spawnPosition.x,
		y = spawnPosition.y,
        canCargo = true,
        mass = cargoWeight
	}
	
	mist.dynAddStatic(cargoTable)
    
    -- smoke the cargo if needed
    if cargoSmoke then 
        local smokePosition={x=spawnPosition.x + mist.random(10,20), y=0, z=spawnPosition.y + mist.random(10,20)}
        local height = veafCas.getLandHeight(smokePosition)
        smokePosition.y = height
        veafCas.logDebug(string.format("spawnCargo: smokePosition  x=%.1f y=%.1f z=%.1f", smokePosition.x, smokePosition.y, smokePosition.z))
        veafCas.generateSmoke(smokePosition, trigger.smokeColor.Green)
        for i = 1, 10 do
            veafCas.logDebug("Signal flare 1 at " .. timer.getTime() + i*7)
            mist.scheduleFunction(veafCas.generateSignalFlare, {smokePosition,trigger.flareColor.Red, mist.random(359)}, timer.getTime() + i*3)
        end
    end

    -- message the unit spawning
    local message = "A cargo of type " .. cargoType .. " weighting " .. cargoWeight .. " kg has been spawned"
    if cargoSmoke ~= "" then 
        message = message .. ". It's marked with green smoke and red flares"
    end
    trigger.action.outText(message, 5)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Smoke and Flare commands
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- add a smoke marker over the marker area
function veafCas.generateSmoke(spawnSpot, color)
	trigger.action.smoke(spawnSpot, color)
end

--- add a signal flare over the marker area
function veafCas.generateSignalFlare(spawnSpot, color, azimuth)
	trigger.action.signalFlare(spawnSpot, color, azimuth)
end

--- add an illumination flare over the target area
function veafCas.generateIlluminationFlare(spawnSpot)
    local vec3 = {x = spawnSpot.x, y = veafCas.getLandHeight(spawnSpot) + 1000, z = spawnSpot.z}
	trigger.action.illuminationBomb(vec3)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafCas.logInfo(string.format("Loading version %s", veafCas.version))
veafCas.logInfo(string.format("Keyphrase   = %s", veafCas.keyphrase))
veafCas.buildRadioMenu()
veafCas.logDebug("land.SurfaceType.WATER = " .. land.SurfaceType.WATER)
veafCas.logDebug("land.SurfaceType.LAND = " .. land.SurfaceType.LAND)
veafCas.logDebug("land.SurfaceType.ROAD = " .. land.SurfaceType.ROAD)
veafCas.logDebug("land.SurfaceType.RUNWAY = " .. land.SurfaceType.RUNWAY)

--- Add event handler.
world.addEventHandler(veafCas.eventHandler)