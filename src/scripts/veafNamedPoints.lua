-- VEAF name point command and functions for DCS World
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- By zip (2018)
--
-- Features:
-- ---------
-- * Listen to marker change events and name the corresponding point, for future reference
-- * Works with all current and future maps (Caucasus, NTTR, Normandy, PG, ...)
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires the base veaf.lua script library (version 1.0 or higher)
-- * It also requires the veafMarkers.lua script library (version 1.0 or higher)
--
-- Basic Usage:
-- ------------
-- 1.) Place a mark on the F10 map.
-- 2.) As text enter "veaf name point, name [the point name]"
-- 3.) Click somewhere else on the map to submit the new text.
-- 4.) The command will be processed. A message will appear to confirm this
-- 5.) The original mark will stay in place, with a text explaining the point name.
--
-- *** NOTE ***
-- * All keywords are CaSE inSenSITvE.
-- * Commas are the separators between options ==> They are IMPORTANT!
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafNamedPoints = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafNamedPoints.Id = "NAMED POINTS - "

--- Version.
veafNamedPoints.Version = "1.0.1"

--- Key phrase to look for in the mark text which triggers the command.
veafNamedPoints.Keyphrase = "veaf name "

veafNamedPoints.Points = {
    --- these points will be processed at initialisation time
}

veafNamedPoints.RadioMenuName = "NAMED POINTS (" .. veafNamedPoints.Version .. ")"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafNamedPoints.namedPoints = {}

veafNamedPoints.rootPath = nil
veafNamedPoints.weatherPath = nil

--- Initial Marker id.
veafNamedPoints.markid=1270000

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafNamedPoints.logInfo(message)
    veaf.logInfo(veafNamedPoints.Id .. message)
end

function veafNamedPoints.logDebug(message)
    veaf.logDebug(veafNamedPoints.Id .. message)
end

function veafNamedPoints.logTrace(message)
    veaf.logTrace(veafNamedPoints.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event handler functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Function executed when a mark has changed. This happens when text is entered or changed.
function veafNamedPoints.onEventMarkChange(eventPos, event)
    -- Check if marker has a text and the veafNamedPoints.keyphrase keyphrase.
    if event.text ~= nil and event.text:lower():find(veafNamedPoints.Keyphrase) then

        -- Analyse the mark point text and extract the keywords.
        local options = veafNamedPoints.markTextAnalysis(event.text)

        if options then
            -- Check options commands
            if options.namepoint then
                -- create the mission
                veafNamedPoints.namePoint(eventPos, options.name, event.coalition)
            end
        else
            -- None of the keywords matched.
            return
        end

        -- Delete old mark.
        veafNamedPoints.logTrace(string.format("Removing mark # %d.", event.idx))
        trigger.action.removeMark(event.idx)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Analyse the mark text and extract keywords.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Extract keywords from mark text.
function veafNamedPoints.markTextAnalysis(text)

    -- Option parameters extracted from the mark text.
    local switch = {}
    switch.namepoint = false

    switch.name = "point"

    -- Check for correct keywords.
    if text:lower():find(veafNamedPoints.Keyphrase .. "point") then
        switch.namepoint = true
    else
        return nil
    end

    -- keywords are split by ","
    local keywords = veaf.split(text, ",")

    for _, keyphrase in pairs(keywords) do
        -- Split keyphrase by space. First one is the key and second, ... the parameter(s) until the next comma.
        local str = veaf.breakString(veaf.trim(keyphrase), " ")
        local key = str[1]
        local val = str[2]

        if key:lower() == "name" then
            -- Set name.
            veafNamedPoints.logDebug(string.format("Keyword name = %s", val))
            switch.name = val
        end
    end

    return switch
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Named points management
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Create the point in the named points database
function veafNamedPoints.namePoint(targetSpot, name, coalition)
    veafNamedPoints.logDebug(string.format("namePoint(name = %s, coalition=%s)",name, coalition))
    veafNamedPoints.logDebug("targetSpot=" .. veaf.vecToString(targetSpot))

    veafNamedPoints.addPoint(name, targetSpot)

    local message = "The point named " .. name .. " has been created. See F10 radio menu for details."
    trigger.action.outText(message,5)

    veafNamedPoints.markid = veafNamedPoints.markid + 1
    trigger.action.markToCoalition(veafNamedPoints.markid, "VEAF - Point named "..name, targetSpot, coalition, true, "VEAF - Point named "..name.." added for own coalition.") 

end

function veafNamedPoints._addPoint(name, point)
    veafNamedPoints.logTrace(string.format("addPoint(name = %s)",name))
    veafNamedPoints.logTrace("point=" .. veaf.vecToString(point))

    veafNamedPoints.namedPoints[name:upper()] = point
end

function veafNamedPoints.addPoint(name, point)
    veafNamedPoints.logTrace(string.format("addPoint: {name=\"%s\",point={x=%d,y=0,z=%d}}", name, point.x, point.z))
    veafNamedPoints._addPoint(name, point)
    veafNamedPoints._refreshWeatherReportsRadioMenu()
end

function veafNamedPoints.delPoint(name)
    veafNamedPoints.logTrace(string.format("delPoint(name = %s)",name))

    table.remove(veafNamedPoints.namedPoints, name:upper())
end

function veafNamedPoints.getPoint(name)
    veafNamedPoints.logTrace(string.format("getPoint(name = %s)",name))

    return veafNamedPoints.namedPoints[name:upper()]
end

function veafNamedPoints.getWeatherAtPoint(parameters)
    local name, groupId = unpack(parameters)
    veafNamedPoints.logTrace(string.format("getWeatherAtPoint(name = %s)",name))
    local point = veafNamedPoints.getPoint(name)
    if point then
        local altitude = veaf.getLandHeight(point)
        local weatherReport = weathermark._WeatherReport(point, altitude, "imperial")
        trigger.action.outTextForGroup(groupId, weatherReport, 30)
    end
end

function veafNamedPoints.buildPointsDatabase()
    veafNamedPoints.namedPoints = {}
    for name, defaultPoint in pairs(veafNamedPoints.Points) do
        veafNamedPoints._addPoint(defaultPoint.name, defaultPoint.point)
    end
end

function veafNamedPoints.listAllPoints(groupId)
    veafNamedPoints.logDebug(string.format("listAllPoints(groupId = %s)",groupId))
    local message = ""
    for name, point in pairs(veafNamedPoints.namedPoints) do
        local lat, lon = coord.LOtoLL(point)
        message = message .. name .. " => " .. mist.tostringLL(lat, lon, 2) .. "\n"
    end

    -- send message only for the group
    trigger.action.outTextForGroup(groupId, message, 30)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu and help
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafNamedPoints._buildWeatherReportsRadioMenuPage(menu, names, pageSize, startIndex)
    veafNamedPoints.logDebug(string.format("veafNamedPoints._buildWeatherReportsRadioMenuPage(pageSize=%d, startIndex=%d)",pageSize, startIndex))
    
    local namesCount = #names
    veafNamedPoints.logTrace(string.format("namesCount = %d",namesCount))

    local endIndex = namesCount
    if endIndex - startIndex >= pageSize then
        endIndex = startIndex + pageSize - 2
    end
    veafNamedPoints.logTrace(string.format("endIndex = %d",endIndex))
    veafNamedPoints.logDebug(string.format("adding commands from %d to %d",startIndex, endIndex))
    for index = startIndex, endIndex do
        local name = names[index]
        veafNamedPoints.logTrace(string.format("names[%d] = %s",index, name))
        local namedPoint = veafNamedPoints.namedPoints[name]
        veafRadio.addCommandToSubmenu( name , menu, veafNamedPoints.getWeatherAtPoint, name, true)    
    end
    if endIndex < namesCount then
        veafNamedPoints.logDebug("adding next page menu")
        local nextPageMenu = veafRadio.addSubMenu("Next page", menu)
        veafNamedPoints._buildWeatherReportsRadioMenuPage(nextPageMenu, names, 10, endIndex+1)
    end
end

--- refresh the Weather Reports radio menu
function veafNamedPoints._refreshWeatherReportsRadioMenu()
    if veafNamedPoints.weatherPath then
        veafNamedPoints.logTrace("deleting weather report submenu")
        veafRadio.delSubmenu(veafNamedPoints.weatherPath, veafNamedPoints.rootPath)
    end
    veafNamedPoints.logTrace("adding weather report submenu")
    veafNamedPoints.weatherPath = veafRadio.addSubMenu("Get weather report over a point", veafNamedPoints.rootPath)
    names = {}
    for name, point in pairs(veafNamedPoints.namedPoints) do
        table.insert(names, name)
    end
    table.sort(names)
    veafNamedPoints._buildWeatherReportsRadioMenuPage(veafNamedPoints.weatherPath, names, 10, 1)
    veafRadio.refreshRadioMenu()
end

--- Build the initial radio menu
function veafNamedPoints.buildRadioMenu()
    veafNamedPoints.rootPath = veafRadio.addSubMenu(veafNamedPoints.RadioMenuName)
    veafRadio.addCommandToSubmenu("HELP", veafNamedPoints.rootPath, veafNamedPoints.help, nil, true)
    veafRadio.addCommandToSubmenu("List all points", veafNamedPoints.rootPath, veafNamedPoints.listAllPoints, nil, true)
    veafNamedPoints._refreshWeatherReportsRadioMenu()
end

--      add ", defense [1-5]" to specify air defense cover on the way (1 = light, 5 = heavy)
--      add ", size [1-5]" to change the number of cargo items to be transported (1 per participating helo, usually)
--      add ", blocade [1-5]" to specify enemy blocade around the drop zone (1 = light, 5 = heavy)
function veafNamedPoints.help(groupId)
    local text =
        'Create a marker and type "veaf name point, name [a name]" in the text\n' ..
        'This will store the position in the named points database for later reference\n'
    trigger.action.outTextForGroup(groupId, text, 30)
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafNamedPoints.initialize()
    veafNamedPoints.buildPointsDatabase()
    veafNamedPoints.buildRadioMenu()
    veafMarkers.registerEventHandler(veafMarkers.MarkerChange, veafNamedPoints.onEventMarkChange)
end

veafNamedPoints.logInfo(string.format("Loading version %s", veafNamedPoints.Version))

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

