-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF cas command and functions for DCS World
-- By zip (2018)
--
-- Features:
-- ---------
-- * Listen to marker change events and creates a CAS training mission, with optional parameters
-- * Possibilities : 
-- *    - create a CAS target group, protected by SAM, AAA and manpads, to use for CAS training
-- * Works with all current and future maps (Caucasus, NTTR, Normandy, PG, ...)
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires the base veaf.lua script library (version 1.0 or higher)
-- * It also requires the veafMarkers.lua script library (version 1.0 or higher)
-- * It also requires the veafCasMission.lua script library (version 1.0 or higher)
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
--     * OPEN --> Browse to the location of veafCasMission.lua and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of this script and click OK.
--     * ACTION "DO SCRIPT"
--     * set the script command to "veafCasMission.initialize()" and click OK.
-- 4.) Save the mission and start it.
-- 5.) Have fun :)
--
-- Basic Usage:
-- ------------
-- 1.) Place a mark on the F10 map.
-- 2.) As text enter "veaf cas mission"
-- 3.) Click somewhere else on the map to submit the new text.
-- 4.) The command will be processed. A message will appear to confirm this
-- 5.) The original mark will disappear.
--
-- Options:
-- --------
-- Type "veaf cas mission" to create a default CAS target group
--      add ", defense 0" to completely disable air defenses
--      add ", defense [1-5]" to specify air defense cover (1 = light, 5 = heavy)
--      add ", size [1-5]" to change the group size (1 = small, 5 = huge)
--      add ", armor [1-5]" to specify armor presence (1 = light, 5 = heavy)
--      add ", spacing [1-5]" to change the groups spacing (1 = dense, 3 = default, 5 = sparse)
--
-- *** NOTE ***
-- * All keywords are CaSE inSenSITvE.
-- * Commas are the separators between options ==> They are IMPORTANT!
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafCasMission = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafCasMission.Id = "CAS MISSION - "

--- Version.
veafCasMission.Version = "1.0.0"

--- Key phrase to look for in the mark text which triggers the weather report.
veafCasMission.Keyphrase = "veaf cas "

--- Number of seconds between each check of the CAS group watchdog function
veafCasMission.SecondsBetweenWatchdogChecks = 15

--- Number of seconds between each smoke request on the CAS targets group
veafCasMission.SecondsBetweenSmokeRequests = 180

--- Number of seconds between each flare request on the CAS targets group
veafCasMission.SecondsBetweenFlareRequests = 120

--- Name of the CAS targets vehicles group 
veafCasMission.RedCasVehiclesGroupName = "Red CAS Group Vehicles"

--- Name of the CAS targets infantry group 
veafCasMission.RedCasInfantryGroupName = "Red CAS Group Infantry"

veafCasMission.RadioMenuName = "CAS MISSION (" .. veafCasMission.Version .. ")"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Radio menus paths
veafCasMission.targetMarkersPath = nil
veafCasMission.targetInfoPath = nil
veafCasMission.rootPath = nil

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

-- CAS Group watchdog function id
veafCasMission.groupAliveCheckTaskID = 'none'

-- Smoke reset function id
veafCasMission.smokeResetTaskID = 'none'    

-- Flare reset function id
veafCasMission.flareResetTaskID = 'none'    

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafCasMission.logInfo(message)
    veaf.logInfo(veafCasMission.Id .. message)
end

function veafCasMission.logDebug(message)
    veaf.logDebug(veafCasMission.Id .. message)
end

function veafCasMission.logTrace(message)
    veaf.logTrace(veafCasMission.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event handler functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Function executed when a mark has changed. This happens when text is entered or changed.
function veafCasMission.onEventMarkChange(eventPos, event)
    -- Check if marker has a text and the veafCasMission.keyphrase keyphrase.
    if event.text ~= nil and event.text:lower():find(veafCasMission.Keyphrase) then

        -- Analyse the mark point text and extract the keywords.
        local options = veafCasMission.markTextAnalysis(event.text)

        if options then
            -- Check options commands
            if options.casmission then
                -- create the group
                veafCasMission.generateCasMission(eventPos, options.size, options.defense, options.armor, options.spacing, options.disperseOnAttack, "Random")
            end
        else
            -- None of the keywords matched.
            return
        end

        -- Delete old mark.
        veafCasMission.logDebug(string.format("Removing mark # %d.", event.idx))
        trigger.action.removeMark(event.idx)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Analyse the mark text and extract keywords.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Extract keywords from mark text.
function veafCasMission.markTextAnalysis(text)

    -- Option parameters extracted from the mark text.
    local switch = {}
    switch.casmission = false

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

    -- Check for correct keywords.
    if text:lower():find(veafCasMission.Keyphrase .. "mission") then
        switch.casmission = true
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

        if switch.casmission and key:lower() == "size" then
            -- Set size.
            veafCasMission.logDebug(string.format("Keyword size = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 1 then
                switch.size = nVal
            end
        end

        if switch.casmission and key:lower() == "defense" then
            -- Set defense.
            veafCasMission.logDebug(string.format("Keyword defense = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 0 then
                switch.defense = nVal
            end
        end

        if switch.casmission and key:lower() == "armor" then
            -- Set armor.
            veafCasMission.logDebug(string.format("Keyword armor = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 0 then
                switch.armor = nVal
            end
        end

        if switch.casmission and key:lower() == "spacing" then
            -- Set spacing.
            veafCasMission.logDebug(string.format("Keyword spacing = %d", val))
            local nVal = tonumber(val)
            if nVal <= 5 and nVal >= 1 then
                switch.spacing = nVal
            end
        end

        if switch.casmission and key:lower() == "disperse" then
            -- Set disperse on attack.
            veafCasMission.logDebug("Keyword disperse is set")
            switch.disperseOnAttack = true
        end
        
    end

    return switch
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CAS target group generation and management
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Generates an air defense group
function veafCasMission.generateAirDefenseGroup(groupId, spawnSpot, defense, armor, skill)
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
        veafCasMission.logDebug("samType = " .. samType)
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, samType, veafCasMission.RedCasVehiclesGroupName .. " Air Defense Group #" .. groupId .. " vehicle #" .. i, skill)
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
        veafCasMission.logDebug("secondary samType = " .. samType)
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, samType, veafCasMission.RedCasVehiclesGroupName .. " Air Defense Group #" .. groupId .. " vehicle #" .. i, skill)
    end

    return vehiclesGroup, infantryGroup
end

--- Generates a transport company and its air defenses
function veafCasMission.generateTransportCompany(groupId, spawnSpot, defense, armor, skill)
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
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, transportType, veafCasMission.RedCasVehiclesGroupName .. " Transport Company #" .. groupId .. " vehicle #" .. i, skill)
    end

    -- add an air defense vehicle
    if defense > 2 then 
        -- defense = 3-5 : add a Shilka
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, "ZSU-23-4 Shilka", veafCasMission.RedCasVehiclesGroupName .. " Transport Company #" .. groupId .. " Air Defense Unit", skill)
    elseif defense > 0 then
        -- defense = 1 : add a ZU23 on a truck
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, "Ural-375 ZU-23", veafCasMission.RedCasVehiclesGroupName .. " Transport Company #" .. groupId .. " Air Defense Unit", skill)
    end

    return vehiclesGroup, infantryGroup
end

--- Generates an armor platoon and its air defenses
function veafCasMission.generateArmorPlatoon(groupId, spawnSpot, defense, armor, skill)
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
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, armorType, veafCasMission.RedCasVehiclesGroupName .. " Armor Platoon #" .. groupId .. " unit #" .. i, skill)
    end

    -- add an air defense vehicle
    if defense > 3 then 
        -- defense = 4-5 : add a Tunguska
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, "2S6 Tunguska", veafCasMission.RedCasVehiclesGroupName .. " Armor Platoon #" .. groupId .. " Air Defense Unit", skill)
    elseif defense > 0 then
        -- defense = 1-3 : add a Shilka
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, "ZSU-23-4 Shilka", veafCasMission.RedCasVehiclesGroupName .. " Armor Platoon #" .. groupId .. " Air Defense Unit", skill)
    end

    return vehiclesGroup, infantryGroup
end

--- Generates an infantry group along with its manpad units and tranport vehicles
function veafCasMission.generateInfantryGroup(groupId, spawnSpot, defense, armor, skill)
    local infantryGroup = {}
    local vehiclesGroup = {}

    -- generate an infantry group
    local groupCount = mist.random(3, 7)
    local dispersion = (groupCount+1) * 5 + 25
    for i = 1, groupCount do
        veaf.addUnit(infantryGroup, spawnSpot, dispersion, "Soldier AK", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " unit #" .. i, skill)
    end

    -- add a transport vehicle
    if armor > 0 then
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, "BTR-80", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " APC", skill)
    else
        veaf.addUnit(vehiclesGroup, spawnSpot, dispersion, "GAZ-3308", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " truck", skill) -- TODO check if tranport type is correct
    end

    -- add manpads if needed
    if defense > 3 then
        -- for defense = 4-5, spawn a full Igla-S team
        veaf.addUnit(infantryGroup, spawnSpot, dispersion, "SA-18 Igla-S comm", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad COMM soldier", skill)
        veaf.addUnit(infantryGroup, spawnSpot, dispersion, "SA-18 Igla-S manpad", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad launcher soldier", skill)
    elseif defense > 0 then
        -- for defense = 1-3, spawn a single Igla soldier
        veaf.addUnit(infantryGroup, spawnSpot, dispersion, "SA-18 Igla manpad", veafCasMission.RedCasInfantryGroupName .. " Infantry Platoon #" .. groupId .. " manpad launcher soldier", skill)
    else
        -- for defense = 0, don't spawn any manpad
    end

    return vehiclesGroup, infantryGroup
end

--- Generates a complete CAS target group
function veafCasMission.generateCasMission(spawnSpot, size, defense, armor, spacing, skill, disperseOnAttack)
    local infantryUnits = {}
    local vehiclesUnits = {}
    local groupId = 1234
    local zoneRadius = (size+spacing-2)*400

    if veafCasMission.groupAliveCheckTaskID ~= 'none' then
        trigger.action.outText("A CAS target group already exists !", 5)
        return 
    end

    -- Move reaper
    -- TODO

    -- generate between size-2 and size+1 infantry groups
    local infantryGroupsCount = mist.random(math.max(1, size-2), size + 1)
    veafCasMission.logDebug("infantryGroupsCount = " .. infantryGroupsCount)
    for i = 1, infantryGroupsCount do
        local groupPosition = veaf.findPointInZone(spawnSpot, zoneRadius, false)
        if groupPosition ~= nil then
            local vehiclesGroup, infantryGroup = veafCasMission.generateInfantryGroup(groupId, groupPosition, defense, armor, skill)
            -- add the units to the global units list
            for _,u in pairs(vehiclesGroup) do
                table.insert(vehiclesUnits, u)
            end
            for _,u in pairs(infantryGroup) do
                table.insert(infantryUnits, u)
            end
        else
            veafCasMission.logInfo("cannot find a suitable position for group "..groupId)
        end
        groupId = groupId + 1
    end

    if armor > 0 then
        -- generate between size-2 and size+1 armor platoons
        local armorPlatoonsCount = mist.random(math.max(1, size-2), size + 1)
        veafCasMission.logDebug("armorPlatoonsCount = " .. armorPlatoonsCount)
        for i = 1, armorPlatoonsCount do
            local groupPosition = veaf.findPointInZone(spawnSpot, zoneRadius, false)
            if groupPosition ~= nil then
                local group = veafCasMission.generateArmorPlatoon(groupId, groupPosition, defense, armor, skill)
                -- add the units to the global units list
                for _,u in pairs(group) do
                    table.insert(vehiclesUnits, u)
                end
            else
                veafCasMission.logInfo("cannot find a suitable position for group "..groupId)
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
        veafCasMission.logDebug("airDefenseGroupsCount = " .. airDefenseGroupsCount)
        for i = 1, airDefenseGroupsCount do
            local groupPosition = veaf.findPointInZone(spawnSpot, zoneRadius, false)
            if groupPosition ~= nil then
                local group = veafCasMission.generateAirDefenseGroup(groupId, groupPosition, defense, armor, skill)
                -- add the units to the global units list
                for _,u in pairs(group) do
                    table.insert(vehiclesUnits, u)
                end
            else
                veafCasMission.logInfo("cannot find a suitable position for group "..groupId)
            end
            groupId = groupId + 1
        end
    end

    -- generate between 1 and size transport companies
    local transportCompaniesCount = mist.random(1, size)
    veafCasMission.logDebug("transportCompaniesCount = " .. transportCompaniesCount)
    for i = 1, transportCompaniesCount do
        local groupPosition = veaf.findPointInZone(spawnSpot, zoneRadius, false)
        if groupPosition ~= nil then
            local group = veafCasMission.generateTransportCompany(groupId, groupPosition, defense, armor, skill)
            -- add the units to the global units list
            for _,u in pairs(group) do
                table.insert(vehiclesUnits, u)
            end
        else
            veafCasMission.logInfo("cannot find a suitable position for group "..groupId)
        end
        groupId = groupId + 1
    end

    -- actually spawn groups
    mist.dynAdd({country = "RUSSIA", category = "GROUND_UNIT", name = veafCasMission.RedCasVehiclesGroupName, hidden = false, units = vehiclesUnits})
    mist.dynAdd({country = "RUSSIA", category = "GROUND_UNIT", name = veafCasMission.RedCasInfantryGroupName, hidden = false, units = infantryUnits})

    -- set AI options for vehicles
    local controller = Group.getByName(veafCasMission.RedCasVehiclesGroupName):getController()
    controller:setOption(9, 2) -- set alarm state to red
    controller:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, disperseOnAttack) -- set disperse on attack according to the option

    -- set AI options for infantry
    controller = Group.getByName(veafCasMission.RedCasInfantryGroupName):getController()
    controller:setOption(9, 2) -- set alarm state to red
    controller:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, disperseOnAttack) -- set disperse on attack according to the option

    -- add radio menu for target information
    missionCommands.addCommand('Target information', veafCasMission.rootPath, veafCasMission.reportTargetInformation)
    
    -- add radio menus for commands
    missionCommands.addCommand('Skip current objective', veafCasMission.rootPath, veafCasMission.skipCasTarget)
    veafCasMission.targetMarkersPath = missionCommands.addSubMenu("Target markers", veafCasMission.rootPath)
    missionCommands.addCommand('Request smoke on target area', veafCasMission.targetMarkersPath, veafCasMission.smokeCasTargetGroup)
    missionCommands.addCommand('Request illumination flare over target area', veafCasMission.targetMarkersPath, veafCasMission.flareCasTargetGroup)

    trigger.action.outText("An enemy group of " .. #vehiclesUnits .. " vehicles and " .. #infantryUnits .. " soldiers has been located. Consult your F10 radio commands for more information.", 5)

    -- start checking for targets destruction
    veafCasMission.casGroupWatchdog()
end

function veafCasMission.reportTargetInformation()
    -- generate information dispatch
    local averageGroupPosition = veaf.getAveragePosition(veafCasMission.RedCasVehiclesGroupName)
    local lat, lon = coord.LOtoLL(averageGroupPosition)
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
    local windDirection, windStrength = veaf.getWind(veaf.placePointOnLand(averageGroupPosition))

    -- add radio menu information messages
    local vehiclesUnits = Group.getByName(veafCasMission.RedCasVehiclesGroupName):getUnits()
    local infantryUnits = Group.getByName(veafCasMission.RedCasInfantryGroupName):getUnits()

    local message =      "TARGET: Group of " .. #vehiclesUnits .. " vehicles and " .. #infantryUnits .. " soldiers.\n"
    message = message .. "\n"
    message = message .. "LAT LON (decimal): " .. mist.tostringLL(lat, lon, 2) .. ".\n"
    message = message .. "LAT LON (DMS)    : " .. mist.tostringLL(lat, lon, 0, true) .. ".\n"
    message = message .. "MGRS/UTM         : " .. mgrsString .. ".\n"
    message = message .. "\n"
    message = message .. "FROM BULLSEYE    : " .. fromBullseye .. ".\n"
    message = message .. "\n"
    message = message .. 'TARGET ALT       : ' .. veaf.getLandHeight(averageGroupPosition) .. " meters.\n"
    message = message .. "\n"
    local windText =     'WIND             : no wind.\n'
    if windStrength > 0 then
        windText = string.format(
                         'WIND             : from %s at %s m/s.\n', windDirection, windStrength)
    end
    message = message .. windText

    trigger.action.outText(message, 15)
end

--- add a smoke marker over the target area
function veafCasMission.smokeCasTargetGroup()
    veafCasMission.logTrace("veafCasMission.smokeCasTargetGroup START")
    veafCasMission.logTrace("veafSpawn.spawnSmoke")
    veafSpawn.spawnSmoke(veaf.getAveragePosition(veafCasMission.RedCasVehiclesGroupName), trigger.smokeColor.Red)
	trigger.action.outText('Copy smoke requested, RED smoke on the deck!',5)
    veafCasMission.logTrace("missionCommands.removeItem")
	missionCommands.removeItem({veaf.RadioMenuName, veafCasMission.RadioMenuName, 'Target markers', 'Request smoke on target area'})
    veafCasMission.logTrace("missionCommands.addCommand")
    missionCommands.addCommand('Target is marked with red smoke', veafCasMission.targetMarkersPath, veaf.emptyFunction)
    veafCasMission.logTrace("mist.scheduleFunction")
    veafCasMission.smokeResetTaskID = mist.scheduleFunction(veafCasMission.smokeReset,{},timer.getTime()+veafCasMission.SecondsBetweenSmokeRequests)
    veafCasMission.logTrace("veafCasMission.smokeCasTargetGroup END")
end

--- Reset the smoke request radio menu
function veafCasMission.smokeReset()
	missionCommands.removeItem({veaf.RadioMenuName, veafCasMission.RadioMenuName, 'Target markers', 'Target is marked with red smoke'})
	missionCommands.addCommand('Request smoke on target area', veafCasMission.targetMarkersPath, veafCasMission.smokeCasTargetGroup)
	trigger.action.outText('Smoke marker available',5)
end

--- add an illumination flare over the target area
function veafCasMission.flareCasTargetGroup()
    veafSpawn.spawnIlluminationFlare(veaf.getAveragePosition(veafCasMission.RedCasVehiclesGroupName))
	trigger.action.outText('Copy illumination flare requested, illumination flare over target area!',5)
	missionCommands.removeItem({veaf.RadioMenuName, veafCasMission.RadioMenuName, 'Target markers', 'Request illumination flare over target area'})
	missionCommands.addCommand('Target area is marked with illumination flare', veafCasMission.targetMarkersPath, veaf.emptyFunction)
    veafCasMission.flareResetTaskID = mist.scheduleFunction(veafCasMission.flareReset,{},timer.getTime()+veafCasMission.SecondsBetweenFlareRequests)
end

--- Reset the flare request radio menu
function veafCasMission.flareReset()
	missionCommands.removeItem({veaf.RadioMenuName, veafCasMission.RadioMenuName, 'Target markers', 'Target area is marked with illumination flare'})
    missionCommands.addCommand('Request illumination flare over target area', veafCasMission.targetMarkersPath, veafCasMission.flareCasTargetGroup)
	trigger.action.outText('Target illumination available',5)
end

--- Checks if the vehicles group is still alive, and if not announces the end of the CAS mission
function veafCasMission.casGroupWatchdog() 
    local group = Group.getByName(veafCasMission.RedCasVehiclesGroupName)
    if group and group:isExist() == true and #group:getUnits() > 0 then
        veafCasMission.logTrace("Group is still alive with "..#group:getUnits().." units")
        veafCasMission.groupAliveCheckTaskID = mist.scheduleFunction(veafCasMission.casGroupWatchdog,{},timer.getTime()+veafCasMission.SecondsBetweenWatchdogChecks)
    else
        trigger.action.outText("CAS objective group destroyed!", 5)
        veafCasMission.cleanupAfterMission()
    end
end

--- Called from the "Skip target" radio menu : remove the current CAS target group
function veafCasMission.skipCasTarget()
    veafCasMission.cleanupAfterMission()
    trigger.action.outText("CAS objective group cleaned up.", 5)
end

--- Cleanup after either mission is ended or aborted
function veafCasMission.cleanupAfterMission()
    veafCasMission.logTrace("skipCasTarget START")

    -- destroy vehicles and infantry groups
    veafCasMission.logTrace("destroy vehicles group")
    local group = Group.getByName(veafCasMission.RedCasVehiclesGroupName)
    if group and group:isExist() == true then
        group:destroy()
    end
    veafCasMission.logTrace("destroy infantry group")
    group = Group.getByName(veafCasMission.RedCasInfantryGroupName)
    if group and group:isExist() == true then
        group:destroy()
    end

    -- remove the watchdog function
    veafCasMission.logTrace("remove the watchdog function")
    if veafCasMission.groupAliveCheckTaskID ~= 'none' then
        mist.removeFunction(veafCasMission.groupAliveCheckTaskID)
    end
    veafCasMission.groupAliveCheckTaskID = 'none'

    -- update the radio menu
    veafCasMission.logTrace("update the radio menu 1")
    missionCommands.removeItem({veaf.RadioMenuName, veafCasMission.RadioMenuName, 'Target information'})
    veafCasMission.logTrace("update the radio menu 2")
    missionCommands.removeItem({veaf.RadioMenuName, veafCasMission.RadioMenuName, 'Skip current objective'})
    veafCasMission.logTrace("update the radio menu 3")
    missionCommands.removeItem({veaf.RadioMenuName, veafCasMission.RadioMenuName, 'Get current objective situation'})
    veafCasMission.logTrace("update the radio menu 4")
    missionCommands.removeItem({veaf.RadioMenuName, veafCasMission.RadioMenuName, 'Target markers'})

    veafCasMission.logTrace("skipCasTarget DONE")

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu and help
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Build the initial radio menu
function veafCasMission.buildRadioMenu()
    veafCasMission.rootPath = missionCommands.addSubMenu(veafCasMission.RadioMenuName, veaf.radioMenuPath)
    missionCommands.addCommand("HELP", veafCasMission.rootPath, veafCasMission.help)
end

function veafCasMission.help()
    local text = 
        'Create a marker and type "veaf cas mission" in the text\n' ..
        'This will create a default CAS target group\n' ..
        'You can add options (comma separated) :\n' ..
        '	"defense 0" completely disables air defenses\n' ..
        '	"defense [1-5]" specifies air defense cover (1 = light, 5 = heavy)\n' ..
        '	"size [1-5]" changes the group size (1 = small, 5 = huge)\n' ..
        '	"armor [1-5]" specifies armor presence (1 = light, 5 = heavy)\n' ..
        '	"spacing [1-5]" changes the groups spacing (1 = dense, 3 = default, 5 = sparse)'
        
    trigger.action.outText(text, 30)
end



-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafCasMission.initialize()
    veafCasMission.buildRadioMenu()
    veafMarkers.registerEventHandler(veafMarkers.MarkerChange, veafCasMission.onEventMarkChange)
end

veafCasMission.logInfo(string.format("Loading version %s", veafCasMission.Version))


