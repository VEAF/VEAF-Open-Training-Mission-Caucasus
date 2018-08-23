-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF Close Air Support mission generator for DCS World
-- Version 0.1
-- By zip (2018)
--
-- Features:
-- ---------
-- * Creates randomized ground unit groups, protected by SAM, AAA and manpads, to use for CAS training
-- * Can be parameterized to fine-tune the level of anti-air defense, type of armor units, group size and spacing.
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
-- 2.) As text enter "veaf cas create".
-- 3.) Click somewhere else on the map to submit the new text.
-- 4.) The ground unit groups will be created. A message will appear to confirm this
-- 5.) The original mark will disappear and a new mark with the target information at the point the mark was set is created.
--
-- Options:
-- --------
-- Type "veaf cas create" to create a default CAS target group
--      add ", defense 0" to completely disable air defenses
--      add ", defense [1-5]" to specify air defense cover (1 = light, 5 = heavy)
--      add ", size [1-5]" to change the group size (1 = small, 5 = huge)
--      add ", armor [1-5]" to specify armor presence (1 = light, 5 = heavy)
--      add ", spacing [1-5]" to change the groups spacing (1 = dense, 3 = default, 5 = sparse)
-- Type "veaf cas smoke" to create a smoke marker 
--      add ", color [red|green]" to specify the smoke color -- TODO document other colors
-- Type "veaf cas flare" to illuminate a zone with a flare
-- Type "veaf cas spawn, type [unit type]" to spawn a specific unit ; types can be any DCS type (replace spaces with the pound character '#'')
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
veafCas.version = "0.1.3"

--- Key phrase to look for in the mark text which triggers the weather report.
veafCas.keyphrase = "veaf cas"

--- DCS bug regarding wrong marker vector components was fixed. If so, set to true!
veafCas.DCSbugfixed = false

--- Enable logDebug mode ==> give more output to DCS log file.
veafCas.Debug = true

--- Number of seconds between each check of the CAS group watchdog function
veafCas.SecondsBetweenWatchdogChecks = 15

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

-- radio menus
veafCas._taskingsRootPath = 'none'
veafCas._taskingsGroundPath = 'none'

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

--- Return the height of the land at the coordinate.
function veafCas.getLandHeight(vec3)
    local vec2 = {x = vec3.x, y = vec3.z}
    -- We add 1 m "safety margin" because data from getlandheight gives the surface and wind at or below the surface is zero!
    return land.getHeight(vec2) + 1
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
    local direction = math.deg(math.atan2(windvec3.z, windvec3.x))
    
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
    local strength=math.sqrt((windvec3.x)^2+(windvec3.z)^2)
    
    -- Debug output.
    veafCas.logDebug(string.format("Wind data: height = %s", tostring(height)))
    veafCas.logDebug(string.format("Wind data: vec3  x=%.1f y=%.1f, z=%.1f", vec3.x, vec3.y, vec3.z))
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
    veafCas.logDebug(string.format("Event id        = %s", tostring(Event.id)))
    veafCas.logDebug(string.format("Event time      = %s", tostring(Event.time)))
    veafCas.logDebug(string.format("Event idx       = %s", tostring(Event.idx)))
    veafCas.logDebug(string.format("Event coalition = %s", tostring(Event.coalition)))
    veafCas.logDebug(string.format("Event group id  = %s", tostring(Event.groupID)))
    veafCas.logDebug(string.format("Event pos X     = %s", tostring(Event.pos.x)))
    veafCas.logDebug(string.format("Event pos Y     = %s", tostring(Event.pos.y)))
    veafCas.logDebug(string.format("Event pos Z     = %s", tostring(Event.pos.z)))
    if Event.initiator ~= nil then
        local _unitname = Event.initiator:getName()
        veafCas.logDebug(string.format("Event ini unit  = %s", tostring(_unitname)))
    end
    veafCas.logDebug(string.format("Event text      = \n%s", tostring(Event.text)))

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
                veafCas.generateUnit(vec3, _options.unitType)
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

    --- size ; ranges from 1 to 5, 5 being the biggest.
    switch.size = 1

    --- defenses force ; ranges from 1 to 5, 5 being the toughest.
    switch.defense = 1

    --- armor force ; ranges from 1 to 5, 5 being the strongest and most modern.
    switch.armor = 1

    --- spacing ; ranges from 1 to 5, 3 being the default and 5 being the widest spacing.
    switch.spacing = 3

    --- disperse on attack ; self explanatory, if keyword is present the option will be set to true
    switch.disperseOnAttack = false

    --- spawned unit type
    switch.unitType = "Hummer"

    --- smoke color
    switch.smokeColor = trigger.smokeColor.Red

    -- Check for correct keywords.
    if text:lower():find(veafCas.keyphrase .. " create") then
        switch.create = true
    elseif text:lower():find(veafCas.keyphrase .. " smoke") then
        switch.smoke = true
    elseif text:lower():find(veafCas.keyphrase .. " flare") then
        switch.flare = true
    elseif text:lower():find(veafCas.keyphrase .. " spawn") then
        switch.spawn = true
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
            if nVal <= 5 and nVal >= 1 then
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
            -- TODO find other colors
            if (val:lower() == "red") then 
                switch.smokeColor = trigger.smokeColor.Red
            elseif (val:lower() == "green") then 
                switch.smokeColor = trigger.smokeColor.Green
            end
        end

    end

    return switch
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CAS target group generation and management
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Find a suitable point for spawning a unit in a <dispersion>-sized circle around a spot
function veafCas.findPointInZone(spawnSpot, dispersion)
    local unitPosition
    local tryCounter = 1000
    repeat -- Place the unit in a "dispersion" ft radius circle from the spawn spot
        unitPosition = mist.getRandPointInCircle(spawnSpot, dispersion)
        tryCounter = tryCounter - 1
    until (land.getSurfaceType(unitPosition) == land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY) or tryCounter == 0
    if tryCounter == 0 then
        return nil
    else
        return unitPosition
    end
end

--- Add a unit to the <group> on a suitable point in a <dispersion>-sized circle around a spot
function veafCas.addUnit(group, spawnSpot, dispersion, unitType, unitName, skill)
    local unitPosition = veafCas.findPointInZone(spawnSpot, dispersion)
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
    local groupCount = 1
    local samType
    local samTypeRand 
    for i = 1, groupCount do
        samTypeRand = mist.random(100)
				
        if samTypeRand > (75-(3*(defense-1))) then
            samType = 'Tor 9A331'
        elseif samTypeRand > (65-(4*(defense-1))) then
            samType = 'Osa 9A33 ln'
        elseif samTypeRand > (50-(4*(defense-1))) then
            samType = '2S6 Tunguska'
        elseif samTypeRand > (30-(5*(defense-1))) then
            samType = 'Strela-10M3'
        else
            samType = 'Strela-1 9P31'
        end
        veafCas.addUnit(vehiclesGroup, spawnSpot, 100, samType, veafCas.RedCasVehiclesGroupName .. " Air Defense Group #" .. groupId .. " vehicle #" .. i, skill)
    end

    -- generate a secondary air defense platoon
    local groupCount = mist.random(1, 3)
    for i = 1, groupCount do
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
        veafCas.addUnit(vehiclesGroup, spawnSpot, 100, samType, veafCas.RedCasVehiclesGroupName .. " Air Defense Group #" .. groupId .. " vehicle #" .. i, skill)
    end

    return vehiclesGroup, infantryGroup
end

--- Generates a transport company and its air defenses
function veafCas.generateTransportCompany(groupId, spawnSpot, defense, armor, skill)
    local infantryGroup = {}
    local vehiclesGroup = {}

    -- generate a transport company
    local groupCount = mist.random(2, 5)
    local dispersion = (groupCount+1) * 15 + 50
    local transportType
    local transportRand
  
    for i = 1, groupCount do
        transportRand = mist.random(8)
        if transportRand == 1 then
            transportType = 'ATMZ-5'
        elseif transportRand == 2 then
            transportType = 'ATMZ-10'            
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
    local dispersion = (groupCount+1) * 15 + 50
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
    local dispersion = (groupCount+1) * 10 + 25
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
    local zoneRadius = (size-2+spacing)*200

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
        local groupPosition = veafCas.findPointInZone(spawnSpot, zoneRadius)
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
            local groupPosition = veafCas.findPointInZone(spawnSpot, zoneRadius)
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
            local groupPosition = veafCas.findPointInZone(spawnSpot, zoneRadius)
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
        local groupPosition = veafCas.findPointInZone(spawnSpot, zoneRadius)
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
    local windDirection, windStrength = veafCas.getWind(averageGroupPosition)

    -- add radio menu information messages
    veafCas._targetInfoPath = missionCommands.addSubMenu("Target information", veafCas._taskingsGroundPath)
    missionCommands.addCommand("TARGET: Group of " .. #vehiclesUnits .. " vehicles and " .. #infantryUnits .. " soldiers.", _targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand("LAT LON: " .. llString .. ".", veafCas._targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand("MGRS/UTM: " .. mgrsString .. ".", veafCas._targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand("FROM BULLSEYE: " .. fromBullseye .. ".", veafCas._targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand('TARGET ALT: ' .. veafCas.getLandHeight(spawnSpot),  veafCas._targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand(string.format("WIND: from %s at %s m/s", windDirection, windStrength),  veafCas._targetInfoPath, veafCas.emptyFunction)
    
    -- add radio menu commands
    missionCommands.removeItem({'Tasking', 'Ground', veafCas.INFO_TEXT})
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
end

--- add an illumination flare over the target area
function veafCas.flareCasTargetGroup()
    veafCas.generateIlluminationFlare(veafCas.getAveragePosition(veafCas.RedCasVehiclesGroupName))
	trigger.action.outText('Copy illumination flare requested, illumination flare over target area!',5)
	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers', 'Request illumination flare over target area'})
	missionCommands.addCommand('Target area is marked with illumination flare', veafCas._targetMarkersPath, veafCas.emptyFunction)
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
    -- TODO add the create transport task info menu
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Unit spawn command
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Spawn a specific unit at a specific spot
function veafCas.spawnUnit(spawnSpot, unitType)
    veafCas.logDebug("generateUnit(spawnSpot = " .. spawnSpot .. ", unitType = " .. unitType .. ")")
  
    local isShip = false
    local units = {}
    local unitName = "VEAF Spawned Unit #" .. mist.random(90000,99999)

    if unitType == "VINSON" or  unitType == "PERRY" or unitType == "TICONDEROG" or unitType == "ALBATROS" or unitType == "KUZNECOW" or unitType == "MOLNIYA" or unitType == "MOSCOW" or unitType == "NEUSTRASH" or unitType == "PIOTR" or unitType == "REZKY" or unitType == "ELNYA" or unitType == "Dry-cargo ship-2" or unitType == "Dry-cargo ship-1" or unitType == "ZWEZDNY" or unitType == "KILO" or unitType == "SOM" or unitType == "speedboat" then
        isShip = true
    end

    -- check spawned position validity
    if isShip then 
        if not(land.getSurfaceType(unitPosition) == land.SurfaceType.isShip) then
            veafCas.logInfo("cannot find a suitable position for spawning naval unit "..unitType)
            trigger.action.outText("cannot find a suitable position for spawning naval unit "..unitType, 5)
            return
        end
    else
        if not(land.getSurfaceType(unitPosition) == land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY) then
            veafCas.logInfo("cannot find a suitable position for spawning ground unit "..unitType)
            trigger.action.outText("cannot find a suitable position for spawning ground unit "..unitType, 5)
            return
        end
    end
  
    -- create the unit
    table.insert(
        units,
        {
            ["x"] = spawnSpot.x,
            ["y"] = spawnSpot.y,
            ["type"] = unitType,
            ["name"] = unitName,
            ["heading"] = 0,
            ["skill"] = "Random"
        }
    )

    -- actually spawn the unit
    local category = "GROUND_UNIT"
    if isShip then 
        category = "SHIP"
    end
    mist.dynAdd({country = "RUSSIA", category = category, name = veafCas.RedSpawnedUnitsGroupName, hidden = false, units = units})

    -- set AI options for the spawned unit
    local controller = Group.getByName(veafCas.RedSpawnedUnitsGroupName):getController()
    controller:setOption(9, 2) -- set alarm state to red
    controller:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, disperseOnAttack) -- set disperse on attack according to the option

    -- message the unit spawning
    trigger.action.outText("An enemy unit of type " .. unitType .. " has been spawned", 5)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Smoke and Flare commands
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- add a smoke marker over the marker area
function veafCas.generateSmoke(spawnSpot, color)
	trigger.action.smoke(spawnSpot, color)
end

--- add an illumination flare over the target area
function veafCas.generateIlluminationFlare(spawnSpot)
    local vec3 = {x = spawnSpot.x, y = spawnSpot.y + 2000, z = spawnSpot.z} -- TODO check if altitude is correct (2000 AGL, but is it meters or feet ?)
	trigger.action.illuminationBomb(vec3)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafCas.logInfo(string.format("Loading version %s", veafCas.version))
veafCas.logInfo(string.format("Keyphrase   = %s", veafCas.keyphrase))
veafCas.buildRadioMenu()

--- Add event handler.
world.addEventHandler(veafCas.eventHandler)