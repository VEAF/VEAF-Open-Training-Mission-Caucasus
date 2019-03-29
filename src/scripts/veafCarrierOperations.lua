-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF carrier command and functions for DCS World
-- By zip (2018)
--
-- Features:
-- ---------
-- * Radio menus allow starting and ending carrier operations. Carriers go back to their initial point when operations are ended
-- * Works with all current and future maps (Caucasus, NTTR, Normandy, PG, ...)
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires the base veaf.lua script library (version 1.0 or higher)
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
--     * OPEN --> Browse to the location of this script and click OK.
--     * ACTION "DO SCRIPT"
--     * set the script command to "veafCarrierOperations.initialize()" and click OK.
-- 4.) Save the mission and start it.
-- 5.) Have fun :)
--
-- Basic Usage:
-- ------------
-- Use the F10 radio menu to start and end carrier operations for every detected carrier group (having a group name like "CSG-*")
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafCarrierOperations = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafCarrierOperations.Id = "CARRIER - "

--- Version.
veafCarrierOperations.Version = "1.1.3"

--- All the carrier groups must comply with this name
veafCarrierOperations.CarrierGroupNamePattern = "^CSG-.*$"

veafCarrierOperations.RadioMenuName = "CARRIER OPS (" .. veafCarrierOperations.Version .. ")"

veafCarrierOperations.AllCarriers = 
{
    ["LHA_Tarawa"] = 0,
    ["Stennis"] = 8, 
    ["KUZNECOW"] = 0
}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Radio menus paths
veafCarrierOperations.rootPath = nil

--- Carrier groups data, for Carrier Operations commands
veafCarrierOperations.carriers = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafCarrierOperations.logInfo(message)
    veaf.logInfo(veafCarrierOperations.Id .. message)
end

function veafCarrierOperations.logDebug(message)
    veaf.logDebug(veafCarrierOperations.Id .. message)
end

function veafCarrierOperations.logTrace(message)
    veaf.logTrace(veafCarrierOperations.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Carrier operations commands
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Start carrier operations ; changes the radio menu item to END and make the carrier move
function veafCarrierOperations.startCarrierOperations(groupName)
    veafCarrierOperations.logDebug("startCarrierOperations(".. groupName .. ")")

    local carrier = veafCarrierOperations.carriers[groupName]

    if not(carrier) then
        local text = "Cannot find the carrier group "..groupName
        veafCarrierOperations.logError(text)
        trigger.action.outText(text, 5)
        return
    end

    -- find the actual carrier unit
    local group = Group.getByName(groupName)
    local carrierUnit = nil
    for _, unit in pairs(group:getUnits()) do
        local unitType = unit:getDesc()["typeName"]
        for knownCarrierType, knownCarrierDeckAngle in pairs(veafCarrierOperations.AllCarriers) do
            if unitType == knownCarrierType then
                carrier.carrierUnitName = unit:getName()
                carrier.deckAngle = knownCarrierDeckAngle
                carrierUnit = unit -- temporary
                break
            end
        end
    end

    -- take note of the starting position
    local startPosition = veaf.getAvgGroupPos(groupName)
    startPosition = { x=startPosition.x, z=startPosition.z, y=startPosition.y+25} -- on deck, 25 meters above the water
    veafCarrierOperations.logTrace("startPosition="..veaf.vecToString(startPosition))

    -- make the carrier move
    if startPosition ~= nil then
	
        --get wind info
        local wind = atmosphere.getWind(startPosition)
        local windspeed = mist.vec.mag(wind)
        veafCarrierOperations.logTrace("windspeed="..windspeed)

        --get wind direction sorted
        local dir = veaf.round(math.atan2(wind.z, wind.x) * 180 / math.pi,0)
        if dir < 0 then
            dir = dir + 360 --converts to positive numbers		
        end
        if dir <= 180 then
            dir = dir + 180
        else
            dir = dir - 180
        end

        dir = dir - carrier.deckAngle --to account for angle of landing deck and movement of the ship
        
        if dir > 360 then
            dir = dir - 360
        end

        veafCarrierOperations.logTrace("dir="..dir)

        local speed = 1
        if windspeed < 12.8611 then
            speed = 12.8611 - windspeed
        end
        veafCarrierOperations.logTrace("speed="..speed)

        -- compute a new waypoint
        if speed > 0 then

            veaf.moveGroupAt(groupName, carrier.carrierUnitName, dir, speed, 1800, carrier.initialPosition, 1000) -- move for 30 minutes with a temp point 1000m from here
            carrier.heading = dir
            carrier.speed = veaf.round(speed * 1.94384, 0)

            local text = 
                "The carrier group "..groupName.." BRC will be " .. carrier.heading .. " (true) at " .. carrier.speed .. " kn \n" ..
                "First it will sail ahead flank to a starting point located roughly on BRC for 1000 m\n" ..
                "This will allow for a better final alignment and will require about 5 minutes\n"

            veafCarrierOperations.logInfo(text)
            trigger.action.outText(text, 25)
    
            carrier.conductingAirOperations = true

            -- change the menu
            veafCarrierOperations.logTrace("change the menu")
            veafCarrierOperations.rebuildRadioMenu()

        end  
    end
end


--- Gets informations about current carrier operations
function veafCarrierOperations.getAtcForCarrierOperations(parameters)
    local groupName, groupId = unpack(parameters)
    veafCarrierOperations.logDebug("getAtcForCarrierOperations(".. groupName .. ")")

    local carrier = veafCarrierOperations.carriers[groupName]
    local carrierUnit = Unit.getByName(carrier.carrierUnitName)
    currentHeading = -1
    currentSpeed = -1
    if carrierUnit then 
        currentHeading = mist.utils.round(mist.utils.toDegree(mist.getHeading(carrierUnit)), 0)
        veafCarrierOperations.logTrace("currentHeading ".. currentHeading)
        currentSpeed = mist.utils.round(mist.utils.mpsToKnots(mist.vec.mag(carrierUnit:getVelocity())),0)
        veafCarrierOperations.logTrace("currentSpeed ".. currentSpeed)
    end

    if not(carrier) then
        local text = "Cannot find the carrier group "..groupName
        veafCarrierOperations.logError(text)
        trigger.action.outText(text, 5)
        return
    end

    local result = ""
    
    if carrier.conductingAirOperations then
        result = "The carrier group "..groupName.." is conducting air operations :\n" ..
        "  - Base Recovery Course " .. carrier.heading .. " (true)\n"
    else
        result = "The carrier group "..groupName.." is not conducting carrier air operations\n"
    end

    if currentHeading > -1 and currentSpeed > -1 then
        result = result ..
        "  - Current heading " .. currentHeading .. " (mag)\n" ..
        "  - Speed " .. currentSpeed .. " kn"
    end

    -- add wind information
    local windDirection, windStrength = veaf.getWind(veaf.placePointOnLand(veaf.getAvgGroupPos(groupName)))
    local windText =     'no wind.\n'
    if windStrength > 0 then
        windText = string.format(
                         'from %s at %s m/s.\n', windDirection, windStrength)
    end
    result = result .. '\nWIND: ' .. windText

    trigger.action.outTextForGroup(groupId, result, 15)

end

--- Ends carrier operations ; changes the radio menu item to START and send the carrier back to its starting point
function veafCarrierOperations.stopCarrierOperations(groupName)
    veafCarrierOperations.logDebug("stopCarrierOperations(".. groupName .. ")")

    local carrier = veafCarrierOperations.carriers[groupName]

    if not(carrier) then
        local text = "Cannot find the carrier group "..groupName
        veafCarrierOperations.logError(text)
        trigger.action.outText(text, 5)
        return
    end

    -- make the carrier move to its initial position
    if carrier.initialPosition ~= nil then
	
        veafCarrierOperations.logTrace("carrier.initialPosition="..veaf.vecToString(carrier.initialPosition))

        local newWaypoint = {
            ["action"] = "Turning Point",
            ["form"] = "Turning Point",
            ["speed"] = 300,  -- ahead flank !
            ["type"] = "Turning Point",
            ["x"] = carrier.initialPosition.x,
            ["y"] = carrier.initialPosition.z,
        }

        -- order group to new waypoint
        mist.goRoute(groupName, {newWaypoint})

        local text = "The carrier group "..groupName.." has stopped air operations ; it's moving back to its initial position"
        veafCarrierOperations.logInfo(text)
        trigger.action.outText(text, 5)

        carrier.conductingAirOperations = false

        -- change the menu
        veafCarrierOperations.logTrace("change the menu")
        veafCarrierOperations.rebuildRadioMenu()
    end

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu and help
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Rebuild the radio menu
function veafCarrierOperations.rebuildRadioMenu()
    veafCarrierOperations.logDebug("veafCarrierOperations.rebuildRadioMenu()")

    -- find the carriers in the veafCarrierOperations.carriers table and prepare their menus
    for name, carrier in pairs(veafCarrierOperations.carriers) do
        veafCarrierOperations.logTrace("rebuildRadioMenu processing "..name)
        
        -- remove the start menu
        if carrier.startMenuName then
            veafCarrierOperations.logTrace("remove carrier.startMenuName="..carrier.startMenuName)
            veafRadio.delCommand(veafCarrierOperations.rootPath, carrier.startMenuName)
        end

        -- remove the stop menu
        if carrier.stopMenuName then
            veafCarrierOperations.logTrace("remove carrier.stopMenuName="..carrier.stopMenuName)
            veafRadio.delCommand(veafCarrierOperations.rootPath, carrier.stopMenuName)
        end

        -- remove the ATC menu (by player group)
        if carrier.getInfoMenuName then
            veafCarrierOperations.logTrace("remove carrier.getInfoMenuName="..carrier.getInfoMenuName)
            veafRadio.delCommand(veafCarrierOperations.rootPath, carrier.getInfoMenuName)
        end

        if carrier.conductingAirOperations then
            -- add the stop menu
            carrier.stopMenuName = name .. " - End air operations"
            veafCarrierOperations.logTrace("add carrier.stopMenuName="..carrier.stopMenuName)
            veafRadio.addCommandToSubmenu(carrier.stopMenuName, veafCarrierOperations.rootPath, veafCarrierOperations.stopCarrierOperations, name)
        else
            -- add the start menu
            carrier.startMenuName = name .. " - Start carrier air operations"
            veafCarrierOperations.logTrace("add carrier.startMenuName="..carrier.startMenuName)
            veafRadio.addCommandToSubmenu(carrier.startMenuName, veafCarrierOperations.rootPath, veafCarrierOperations.startCarrierOperations, name)
        end

        -- add the ATC menu (by player group)
        carrier.getInfoMenuName = name .. " - ATC - Request informations"
        veafCarrierOperations.logTrace("add carrier.getInfoMenuName="..carrier.getInfoMenuName)
        veafRadio.addCommandToSubmenu(carrier.getInfoMenuName, veafCarrierOperations.rootPath, veafCarrierOperations.getAtcForCarrierOperations, name, true)

        veafRadio.refreshRadioMenu()
    end
end

--- Build the initial radio menu
function veafCarrierOperations.buildRadioMenu()
    veafCarrierOperations.logDebug("veafCarrierOperations.buildRadioMenu")

    veafCarrierOperations.rootPath = veafRadio.addSubMenu(veafCarrierOperations.RadioMenuName)

    -- build HELP menu for each group
    veafRadio.addCommandToSubmenu("HELP", veafCarrierOperations.rootPath, veafCarrierOperations.help, true)

    -- find the carriers and add them to the veafCarrierOperations.carriers table, store its initial location and create the menus
    for name, group in pairs(mist.DBs.groupsByName) do
        veafCarrierOperations.logTrace("found group "..name)
        if name:match(veafCarrierOperations.CarrierGroupNamePattern) then
            veafCarrierOperations.carriers[name] = {}
            local carrier = veafCarrierOperations.carriers[name]
            veafCarrierOperations.logTrace("found carrier !")

            -- find the actual carrier unit
            local group = Group.getByName(name)
            local carrierUnit = nil
            for _, unit in pairs(group:getUnits()) do
                local unitType = unit:getDesc()["typeName"]
                for knownCarrierType, knownCarrierDeckAngle in pairs(veafCarrierOperations.AllCarriers) do
                    if unitType == knownCarrierType then
                        carrier.carrierUnitName = unit:getName()
                        carrier.deckAngle = knownCarrierDeckAngle
                        carrierUnit = unit -- temporary
                        break
                    end
                end
            end

            -- take note of the starting position, heading and speed
            carrier.initialPosition = veaf.getAvgGroupPos(name)
            veafCarrierOperations.logTrace("carrier.initialPosition="..veaf.vecToString(carrier.initialPosition))

        end
    end

    veafCarrierOperations.rebuildRadioMenu()
end

function veafCarrierOperations.help()
    local text =
        'Use the radio menus to start and end carrier operations\n' ..
        'START: carrier will find out the wind and set sail at optimum speed to achieve a 25kn headwind\n' ..
        '       the radio menu will show the recovery course and TACAN information\n' ..
        'END  : carrier will go back to its starting point (where it was when the START command was issued)\n' ..
        'RESET: carrier will go back to where it was when the mission started'

    trigger.action.outText(text, 30)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafCarrierOperations.initialize()
    veafCarrierOperations.buildRadioMenu()
end

veafCarrierOperations.logInfo(string.format("Loading version %s", veafCarrierOperations.Version))

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)



