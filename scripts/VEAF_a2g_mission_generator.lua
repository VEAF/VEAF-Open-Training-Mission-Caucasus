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
-- 2.) As text enter "veaf cas mission".
-- 3.) Click somewhere else on the map to submit the new text.
-- 4.) The ground unit groups will be created. A message will appear to confirm this
-- 5.) The original mark will disappear and a new mark with the target information at the point the mark was set is created.
--
-- Options:
-- --------
-- Type "veaf cas mission, defense 0" to completely disable air defenses
-- Type "veaf cas mission, size [1-5]" to change the group size
-- TODO document other options
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
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Version.
veafCas.version = "0.1.1"

--- Identifier. All output in DCS.log will start with this.
veafCas.id = "VEAF "

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
        -- TODO: This needs to be "fixed", once DCS gives the correct numbers for x and z.
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
                -- TODO
            elseif _options.flare then
                -- TODO
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
            switch.unitType = nVal
        end

    end

    return switch
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CAS target group generation and management
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafCas.generateAirDefenseGroup(groupId, spawnSpot, defense, armor, skill)
    -- generate an air defense group
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

function veafCas.generateTransportCompany(groupId, spawnSpot, defense, armor, skill)
    -- generate a transport company and its air defenses
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
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, unitTypes.vehicles.SAM.ZSU234_Shilka, veafCas.RedCasVehiclesGroupName .. " Transport Company #" .. groupId .. " Air Defense Unit", skill)
    elseif defense > 0 then
        -- defense = 1 : add a ZU23 on a truck
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, unitTypes.vehicles.SAM.Ural375_ZU23, veafCas.RedCasVehiclesGroupName .. " Transport Company #" .. groupId .. " Air Defense Unit", skill)
    end

    return vehiclesGroup, infantryGroup
end

function veafCas.generateArmorPlatoon(groupId, spawnSpot, defense, armor, skill)
    -- generate an armor platoon and its air defenses
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
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, unitTypes.vehicles.SAM._2S6_Tunguska, veafCas.RedCasVehiclesGroupName .. " Armor Platoon #" .. groupId .. " Air Defense Unit", skill)
    elseif defense > 0 then
        -- defense = 1-3 : add a Shilka
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, unitTypes.vehicles.SAM.ZSU234_Shilka, veafCas.RedCasVehiclesGroupName .. " Armor Platoon #" .. groupId .. " Air Defense Unit", skill)
    end

    return vehiclesGroup, infantryGroup
end

-- generate an infantry group along with its manpad units and tranport vehicles
function veafCas.generateInfantryGroup(groupId, spawnSpot, defense, armor, skill)
    local infantryGroup = {}
    local vehiclesGroup = {}

    -- generate an infantry group
    local groupCount = mist.random(3, 7)
    local dispersion = (groupCount+1) * 10 + 25
    for i = 1, groupCount do
        veafCas.addUnit(infantryGroup, spawnSpot, dispersion, unitTypes.vehicles.IFV.Soldier_AK, veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " unit #" .. i, skill)
    end

    -- add a transport vehicle
    if armor > 0 then
        veafCas.addUnit(vehiclesGroup, spawnSpot, dispersion, unitTypes.vehicles.IFV.BTR80, veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " APC", skill)
    end

    -- add manpads if needed
    if defense > 3 then
        -- for defense = 4-5, spawn a full Igla-S team
        veafCas.addUnit(infantryGroup, spawnSpot, dispersion, unitTypes.vehicles.SAM.SA18_IglaS_comm, veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad COMM soldier", skill)
        veafCas.addUnit(infantryGroup, spawnSpot, dispersion, unitTypes.vehicles.SAM.SA18_IglaS_manpad, veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad launcher soldier", skill)
    elseif defense > 0 then
        -- for defense = 1-3, spawn a single Igla soldier
        veafCas.addUnit(infantryGroup, spawnSpot, dispersion, unitTypes.vehicles.SAM.SA18_Igla_manpad, veafCas.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad launcher soldier", skill)
    else
        -- for defense = 0, don't spawn any manpad
    end

    return vehiclesGroup, infantryGroup
end

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
    -- TODO

    -- add radio menu information messages
    _targetInfoPath = missionCommands.addSubMenu("Target information", veafCas._taskingsGroundPath)
    missionCommands.addCommand("TARGET: Group of " .. #vehiclesUnits .. " vehicles and " .. #infantryUnits .. " soldiers.", _targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand("LAT LON: " .. llString .. ".", _targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand("MGRS/UTM: " .. mgrsString .. ".", _targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand('TARGET ALT: ' .. veafCas.getLandHeight(spawnSpot),  _targetInfoPath, veafCas.emptyFunction)
    missionCommands.addCommand("FROM BULLSEYE: " .. fromBullseye .. ".", _targetInfoPath, veafCas.emptyFunction)

    -- add radio menu commands
    _targetMarkersPath = missionCommands.addSubMenu("Target markers", veafCas._taskingsGroundPath)
    -- TODO add smoke radio command
    -- TODO add flare radio command
    missionCommands.addCommand("Skip current CAS target", veafCas._taskingsGroundPath, veafCas.skipCasTarget)

    trigger.action.outText("An enemy group of " .. #vehiclesUnits .. " vehicles and " .. #infantryUnits .. " soldiers has been located. Consult your F10 radio commands for more information.", 5)

    -- start checking for targets destruction
    veafCas.casGroupWatchdog()
end

function veafCas.casGroupWatchdog() 
    local group = Group.getByName(veafCas.RedCasVehiclesGroupName)
    if group and group:isExist() == true and #group:getUnits() > 0 then
        veafCas.groupAliveCheckTaskID = mist.scheduleFunction(veafCas.casGroupWatchdog,{},timer.getTime()+veafCas.SecondsBetweenWatchdogChecks)
    else
        trigger.action.outText("Objective group destroyed!", 5)
        veafCas.cleanupAfterMission()
    end
end

function veafCas.skipCasTarget()
    trigger.action.outText("Skipping CAS objective group ; please stand by...", 5)
    veafCas.cleanupAfterMission()
    trigger.action.outText("CAS objective group cleaned up.", 5)
end

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
    -- TODO add the create task info menu
end

function veafCas.buildRadioMenu()
    veafCas._taskingsRootPath = missionCommands.addSubMenu('Tasking')
    veafCas._taskingsGroundPath = missionCommands.addSubMenu('Ground', veafCas._taskingsRootPath)
    -- TODO add the create task info menu
    -- TODO add the create transport task info menu
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Unit spawn command
-------------------------------------------------------------------------------------------------------------------------------------------------------------
function veafCas.spawnUnit(spawnSpot, unitType)
    veafCas.logDebug("generateUnit(spawnSpot = " .. spawnSpot .. ", unitType = " .. unitType .. ")")
  
    local units = {}
    local unitName = "VEAF Spawned Unit #" .. mist.random(90000,99999)

    -- check spawned position validity (TODO spawn ships over water)
    if not(land.getSurfaceType(unitPosition) == land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY) then
        veafCas.logInfo("cannot find a suitable position for spawning unit "..unitType)
        trigger.action.outText("cannot find a suitable position for spawning unit "..unitType, 5)
        return
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
    mist.dynAdd({country = "RUSSIA", category = "GROUND_UNIT", name = veafCas.RedSpawnedUnitsGroupName, hidden = false, units = units})

    -- set AI options for the spawned unit
    local controller = Group.getByName(veafCas.RedSpawnedUnitsGroupName):getController()
    controller:setOption(9, 2) -- set alarm state to red
    controller:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, disperseOnAttack) -- set disperse on attack according to the option

    -- message the unit spawning
    trigger.action.outText("An enemy unit of type " .. unitType .. " has been spawned", 5)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------
veafCas.logInfo(string.format("Loading version %s", veafCas.version))
veafCas.logInfo(string.format("Keyphrase   = %s", veafCas.keyphrase))
veafCas.buildRadioMenu()

--- Add event handler.
world.addEventHandler(veafCas.eventHandler)

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Unit types table
-------------------------------------------------------------------------------------------------------------------------------------------------------------

unitTypes = {}
unitTypes.navy = {}
unitTypes.navy.blue = {
  VINSON = "VINSON",
  PERRY = "PERRY",
  TICONDEROG = "TICONDEROG"
}
unitTypes.navy.red = {
  ALBATROS = "ALBATROS",
  KUZNECOW = "KUZNECOW",
  MOLNIYA = "MOLNIYA",
  MOSCOW = "MOSCOW",
  NEUSTRASH = "NEUSTRASH",
  PIOTR = "PIOTR",
  REZKY = "REZKY"
}
unitTypes.navy.civil = {
  ELNYA = "ELNYA",
  Drycargo_ship2 = "Dry-cargo ship-2",
  Drycargo_ship1 = "Dry-cargo ship-1",
  ZWEZDNY = "ZWEZDNY"
}
unitTypes.navy.submarine = {
  KILO = "KILO",
  SOM = "SOM"
}
unitTypes.navy.speedboat = {
  speedboat = "speedboat"
}
unitTypes.vehicles = {}
unitTypes.vehicles.Howitzers = {
  _2B11_mortar = "2B11 mortar",
  SAU_Gvozdika = "SAU Gvozdika",
  SAU_Msta = "SAU Msta",
  SAU_Akatsia = "SAU Akatsia",
  SAU_2C9 = "SAU 2-C9",
  M109 = "M-109"
}
unitTypes.vehicles.IFV = {
  AAV7 = "AAV7",
  BMD1 = "BMD-1",
  BMP1 = "BMP-1",
  BMP2 = "BMP-2",
  BMP3 = "BMP-3",
  Boman = "Boman",
  BRDM2 = "BRDM-2",
  BTR80 = "BTR-80",
  BTR_D = "BTR_D",
  Bunker = "Bunker",
  Cobra = "Cobra",
  LAV25 = "LAV-25",
  M1043_HMMWV_Armament = "M1043 HMMWV Armament",
  M1045_HMMWV_TOW = "M1045 HMMWV TOW",
  M1126_Stryker_ICV = "M1126 Stryker ICV",
  M113 = "M-113",
  M1134_Stryker_ATGM = "M1134 Stryker ATGM",
  M2_Bradley = "M-2 Bradley",
  Marder = "Marder",
  MCV80 = "MCV-80",
  MTLB = "MTLB",
  Paratrooper_RPG16 = "Paratrooper RPG-16",
  Paratrooper_AKS74 = "Paratrooper AKS-74",
  Sandbox = "Sandbox",
  Soldier_AK = "Soldier AK",
  Infantry_AK = "Infantry AK",
  Soldier_M249 = "Soldier M249",
  Soldier_M4 = "Soldier M4",
  Soldier_M4_GRG = "Soldier M4 GRG",
  Soldier_RPG = "Soldier RPG",
  TPZ = "TPZ"
}
unitTypes.vehicles.MLRS = {
  GradURAL = "Grad-URAL",
  Uragan_BM27 = "Uragan_BM-27",
  Smerch = "Smerch",
  MLRS = "MLRS"
}
unitTypes.vehicles.SAM = {
  _2S6_Tunguska = "2S6 Tunguska",
  Kub_2P25_ln = "Kub 2P25 ln",
  _5p73_s125_ln = "5p73 s-125 ln",
  S300PS_5P85C_ln = "S-300PS 5P85C ln",
  S300PS_5P85D_ln = "S-300PS 5P85D ln",
  SA11_Buk_LN_9A310M1 = "SA-11 Buk LN 9A310M1",
  Osa_9A33_ln = "Osa 9A33 ln",
  Tor_9A331 = "Tor 9A331",
  Strela10M3 = "Strela-10M3",
  Strela1_9P31 = "Strela-1 9P31",
  SA11_Buk_CC_9S470M1 = "SA-11 Buk CC 9S470M1",
  SA8_Osa_LD_9T217 = "SA-8 Osa LD 9T217",
  Patriot_AMG = "Patriot AMG",
  Patriot_ECS = "Patriot ECS",
  Gepard = "Gepard",
  Hawk_pcp = "Hawk pcp",
  SA18_Igla_manpad = "SA-18 Igla manpad",
  SA18_Igla_comm = "SA-18 Igla comm",
  Igla_manpad_INS = "Igla manpad INS",
  SA18_IglaS_manpad = "SA-18 Igla-S manpad",
  SA18_IglaS_comm = "SA-18 Igla-S comm",
  Vulcan = "Vulcan",
  Hawk_ln = "Hawk ln",
  M48_Chaparral = "M48 Chaparral",
  M6_Linebacker = "M6 Linebacker",
  Patriot_ln = "Patriot ln",
  M1097_Avenger = "M1097 Avenger",
  Patriot_EPP = "Patriot EPP",
  Patriot_cp = "Patriot cp",
  Roland_ADS = "Roland ADS",
  S300PS_54K6_cp = "S-300PS 54K6 cp",
  Stinger_manpad_GRG = "Stinger manpad GRG",
  Stinger_manpad_dsr = "Stinger manpad dsr",
  Stinger_comm_dsr = "Stinger comm dsr",
  Stinger_manpad = "Stinger manpad",
  Stinger_comm = "Stinger comm",
  ZSU234_Shilka = "ZSU-23-4 Shilka",
  ZU23_Emplacement_Closed = "ZU-23 Emplacement Closed",
  ZU23_Emplacement = "ZU-23 Emplacement",
  ZU23_Closed_Insurgent = "ZU-23 Closed Insurgent",
  Ural375_ZU23_Insurgent = "Ural-375 ZU-23 Insurgent",
  ZU23_Insurgent = "ZU-23 Insurgent",
  Ural375_ZU23 = "Ural-375 ZU-23"
}
unitTypes.vehicles.radar = {
  _1L13_EWR = "1L13 EWR",
  Kub_1S91_str = "Kub 1S91 str",
  S300PS_40B6M_tr = "S-300PS 40B6M tr",
  S300PS_40B6MD_sr = "S-300PS 40B6MD sr",
  _55G6_EWR = "55G6 EWR",
  S300PS_64H6E_sr = "S-300PS 64H6E sr",
  SA11_Buk_SR_9S18M1 = "SA-11 Buk SR 9S18M1",
  Dog_Ear_radar = "Dog Ear radar",
  Hawk_tr = "Hawk tr",
  Hawk_sr = "Hawk sr",
  Patriot_str = "Patriot str",
  Hawk_cwar = "Hawk cwar",
  p19_s125_sr = "p-19 s-125 sr",
  Roland_Radar = "Roland Radar",
  snr_s125_tr = "snr s-125 tr"
}
unitTypes.vehicles.Structures = {
  house1arm = "house1arm",
  house2arm = "house2arm",
  outpost_road = "outpost_road",
  outpost = "outpost",
  houseA_arm = "houseA_arm"
}
unitTypes.vehicles.Tanks = {
  Challenger2 = "Challenger2",
  Leclerc = "Leclerc",
  Leopard1A3 = "Leopard1A3",
  Leopard2 = "Leopard-2",
  M60 = "M-60",
  M1128_Stryker_MGS = "M1128 Stryker MGS",
  M1_Abrams = "M-1 Abrams",
  T55 = "T-55",
  T72B = "T-72B",
  T80UD = "T-80UD",
  T90 = "T-90"
}
unitTypes.vehicles.unarmed = {
  Ural4320_APA5D = "Ural-4320 APA-5D",
  ATMZ5 = "ATMZ-5",
  ATZ10 = "ATZ-10",
  GAZ3307 = "GAZ-3307",
  GAZ3308 = "GAZ-3308",
  GAZ66 = "GAZ-66",
  M978_HEMTT_Tanker = "M978 HEMTT Tanker",
  HEMTT_TFFT = "HEMTT TFFT",
  IKARUS_Bus = "IKARUS Bus",
  KAMAZ_Truck = "KAMAZ Truck",
  LAZ_Bus = "LAZ Bus",
  Hummer = "Hummer",
  M_818 = "M 818",
  MAZ6303 = "MAZ-6303",
  Predator_GCS = "Predator GCS",
  Predator_TrojanSpirit = "Predator TrojanSpirit",
  Suidae = "Suidae",
  Tigr_233036 = "Tigr_233036",
  Trolley_bus = "Trolley bus",
  UAZ469 = "UAZ-469",
  Ural_ATsP6 = "Ural ATsP-6",
  Ural375_PBU = "Ural-375 PBU",
  Ural375 = "Ural-375",
  Ural432031 = "Ural-4320-31",
  Ural4320T = "Ural-4320T",
  VAZ_Car = "VAZ Car",
  ZiL131_APA80 = "ZiL-131 APA-80",
  SKP11 = "SKP-11",
  ZIL131_KUNG = "ZIL-131 KUNG",
  ZIL4331 = "ZIL-4331"
}