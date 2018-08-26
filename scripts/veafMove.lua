-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF move units for DCS World
-- By mitch (2018)
--
-- Features:
-- ---------
-- * Listen to marker change events and execute move commands, with optional parameters
-- * Possibilities : 
-- *    - move a specific group to a marker point, at a specific speed
-- *    - create a new tanker flightplan, moving a specific tanker group
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
--     * set the script command to "veafMove.initialize()" and click OK.
-- 4.) Save the mission and start it.
-- 5.) Have fun :)
--
-- Basic Usage:
-- ------------
-- 1.) Place a mark on the F10 map.
-- 2.) As text enter "veaf move group" or "veaf move tanker"
-- 3.) Click somewhere else on the map to submit the new text.
-- 4.) The command will be processed. A message will appear to confirm this
-- 5.) The original mark will disappear.
--
-- Options:
-- --------
-- Type "veaf move group, name [groupname]" to move the specified group to the marker point
--      add ", speed [speed]" to make the group move and at the specified speed (in knots)
-- Type "veaf move tanker, name [groupname]" to create a new tanker flight plan and move the specified tanker.
--      add ", speed [speed]" to make the tanker move and execute its refuel mission at the specified speed (in knots)
--      add ", hdg [heading]" to specify the refuel leg heading (from the marker point, in degrees)
--      add ", dist [distance]" to specify the refuel leg length (from the marker point, in nautical miles)
--      add ", alt [altitude]" to specify the refuel leg altitude (in feet)
--
-- *** NOTE ***
-- * All keywords are CaSE inSenSITvE.
-- * Commas are the separators between options ==> They are IMPORTANT!
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- veafMove Table.
veafMove = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafMove.Id = "MOVE - "

--- Version.
veafMove.Version = "1.0.0"

--- Key phrase to look for in the mark text which triggers the weather report.
veafMove.Keyphrase = "veaf move "

veafMove.RadioMenuName = "MOVE (" .. veafMove.Version .. ")"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafMove.rootPath = nil

--- Initial Marker id.
veafMove.markid = 20000

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafMove.logInfo(message)
    veaf.logInfo(veafMove.Id .. message)
end

function veafMove.logDebug(message)
    veaf.logDebug(veafMove.Id .. message)
end

function veafMove.logTrace(message)
    veaf.logTrace(veafMove.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event handler functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Function executed when a mark has changed. This happens when text is entered or changed.
function veafMove.onEventMarkChange(eventPos, event)
    -- Check if marker has a text and the veafMove.keyphrase keyphrase.
    if event.text ~= nil and event.text:lower():find(veafMove.Keyphrase) then

        -- Analyse the mark point text and extract the keywords.
        local options = veafMove.markTextAnalysis(event.text)
        local result = false

        if options then
            -- Check options commands
            if options.moveGroup then
                result = veafMove.moveGroup(eventPos, options.groupName, options.speed)
            elseif options.moveTanker then
                result = veafMove.moveTanker(eventPos, options.groupName, options.speed, options.heading, options.distance, options.altitude)
            end
        else
            -- None of the keywords matched.
            return
        end

        if result then 
            -- Add a new mark
            local lat, lon = coord.LOtoLL(eventPos)
            local llString = mist.tostringLL(lat, lon, 0, true)
        
            local markText = "Group " .. options.groupName .. " moving here at " .. options.speed .. " kn"
            local message = veafMove.Id .. "Group " .. options.groupName .. " moving to ".. llString .. " at " .. options.speed .. " kn"
            if options.moveTanker then
                markText = "Tanker " .. options.groupName .. " refuel leg at " .. options.speed .. " kn, " .. options.altitude .. " ft, heading " .. options.heading .. " for " .. options.distance .. " nm"
                message = veafMove.Id .. "Tanker " .. options.groupName .. " initiating new refuel leg from ".. llString .. ", at " .. options.speed .. " kn, " .. options.altitude .. " ft, heading " .. options.heading .. " for " .. options.distance .. " nm"
            end
            veafMove.logDebug("Adding a new mark")
            trigger.action.markToCoalition(veafMove.markid, markText, eventPos, event.coalition , false, message)
            veafMove.markid = veafMove.markid + 1

            -- Delete old mark.
            veafMove.logDebug(string.format("Removing mark # %d.", event.idx))
            trigger.action.removeMark(event.idx)

        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Analyse the mark text and extract keywords.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Extract keywords from mark text.
function veafMove.markTextAnalysis(text)

    -- Option parameters extracted from the mark text.
    local switch = {}
    switch.moveGroup = false
    switch.moveTanker = false

    -- the name of the group to move ; mandatory
    switch.groupName = ""

    -- speed in knots
    switch.speed = 0

    -- tanker refuel leg altitude in feet
    switch.altitude = 20000

    -- tanker refuel leg distance in nautical miles
    switch.distance = 20

    -- tanker refuel leg heading in degrees
    switch.heading = 0

    -- Check for correct keywords.
    if text:lower():find(veafMove.Keyphrase .. "group") then
        switch.moveGroup = true
        switch.speed = 20
    elseif text:lower():find(veafMove.Keyphrase .. "tanker") then
        switch.moveTanker = true
        switch.speed = 250
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

        if (switch.moveTanker or switch.moveGroup) and key:lower() == "name" then
            -- Set group name
            veafSpawn.logDebug(string.format("Keyword name = %s", val))
            switch.groupName = val
        end

        if (switch.moveTanker or switch.moveGroup) and key:lower() == "speed" then
            -- Set size.
            veafMove.logDebug(string.format("Keyword speed = %d", val))
            local nVal = tonumber(val)
            switch.speed = nVal
        end

        if switch.moveTanker and key:lower() == "alt" then
            -- Set size.
            veafMove.logDebug(string.format("Keyword alt = %d", val))
            local nVal = tonumber(val)
            switch.altitude = nVal
        end

        if switch.moveTanker and key:lower() == "dist" then
            -- Set size.
            veafMove.logDebug(string.format("Keyword dist = %d", val))
            local nVal = tonumber(val)
            switch.distance = nVal
        end

        if switch.moveTanker and key:lower() == "hdg" then
            -- Set size.
            veafMove.logDebug(string.format("Keyword hdg = %d", val))
            local nVal = tonumber(val)
            switch.heading = nVal
        end

    end

    -- check mandatory parameter "group"
    if not(switch.groupName) then return nil end
    return switch
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Group move command
-------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- veafMove.moveGroup
-- @param point eventPos
-- @param string groupName the group name to move on
-- @param float speed in knots
------------------------------------------------------------------------------
function veafMove.moveGroup(eventPos, groupName, speed)
    veafMove.logDebug("veafMove.moveGroup(groupName = " .. groupName .. ", speed = " .. speed)
    veafSpawn.logDebug(string.format("veafMove.moveGroup: eventPos  x=%.1f y=%.1f", eventPos.x, eventPos.y))


	local unitGroup = Group.getByName(groupName)
    if unitGroup == nil then
        veafMove.logInfo(groupName .. ' not found for move group command')
		trigger.action.outText(groupName .. ' not found for move group command' , 10)
		return false
	end
	
	-- new route point
	local newWaypoint = {
		["action"] = "Turning Point",
		["alt"] = 0,
		["alt_type"] = "BARO",
		["form"] = "Turning Point",
		["speed"] = speed/1.94384,  -- speed in m/s
		["type"] = "Turning Point",
		["x"] = eventPos.x,
		["y"] = eventPos.y,
	}

	-- order group to new waypoint
	mist.goRoute(groupName, {newWaypoint})

    return true
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Tanker move command
-------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- veafMove.moveTanker
-- @param point eventPos
-- @param string groupName 
-- @param float speed in knots
-- @param float hdg heading (0-359)
-- @param float distance in Nm
-- @param float alt in feet
------------------------------------------------------------------------------
function veafMove.moveTanker(eventPos, groupName, speed, hdg ,distance,alt)
    veafMove.logDebug("veafMove.moveGroup(groupName = " .. groupName .. ", speed = " .. speed .. ", hdg = " .. hdg .. ", distance = " .. distance .. ", alt = " .. alt)
    veafSpawn.logDebug(string.format("veafMove.moveGroup: eventPos  x=%.1f y=%.1f", eventPos.x, eventPos.y))

	local unitGroup = Group.getByName(groupName)
	if unitGroup == nil then
        veafMove.logInfo(groupName .. ' not found for move tanker command')
		trigger.action.outText(groupName .. ' not found for move tanker command' , 10)
		return false
	end

	-- starting position
	local fromPosition = eventPos
	
	-- ending position
	local toPosition = {
		["x"] = fromPosition.x + distance * 1000 * 0.539957 * math.cos(mist.utils.toRadian(hdg)),
		["y"] = fromPosition.y + distance * 1000 * 0.539957 * math.sin(mist.utils.toRadian(hdg)),
	}

	local mission = { 
		id = 'Mission', 
		params = { 
			["communication"] = true,
			["start_time"] = 0,
			--["frequency"] = 253,
			--["radioSet"] = true,
			["task"] = "Refueling",
			route = { 
				points = { 
					-- first point
					[1] = { 
						["type"] = "Turning Point",
						["action"] = "Turning Point",
						["x"] = fromPosition.x,
						["y"] = fromPosition.y,
						["alt"] = alt * 0.3048, -- in meters
						["alt_type"] = "BARO", 
						["speed"] = speed/1.94384,  -- speed in m/s
						["speed_locked"] = boolean, 
						["task"] = 
						{
							["id"] = "ComboTask",
							["params"] = 
							{
								["tasks"] = 
								{
									[1] = 
									{
										["enabled"] = true,
										["auto"] = true,
										["id"] = "Tanker",
										["number"] = 1,
									}, -- end of [1]
								}, -- end of ["tasks"]
							}, -- end of ["params"]
						}, -- end of ["task"]
					}, -- enf of [1]
					[2] = 
					{
						["type"] = "Turning Point",
						["alt"] = alt * 0.3048, -- in meters
						["action"] = "Turning Point",
						["alt_type"] = "BARO",
						["speed"] = speed/1.94384,
						["speed_locked"] = true,
						["x"] = toPosition.x,
						["y"] = toPosition.y,
						["task"] = 
						{
							["id"] = "ComboTask",
							["params"] = 
							{
								["tasks"] = 
								{
									[1] = 
									{
										["enabled"] = true,
										["auto"] = false,
										["id"] = "WrappedAction",
										["number"] = 1,
										["params"] = 
										{
											["action"] = 
											{
												["id"] = "SwitchWaypoint",
												["params"] = 
												{
													["goToWaypointIndex"] = 1,
													["fromWaypointIndex"] = 2,
												}, -- end of ["params"]
											}, -- end of ["action"]
										}, -- end of ["params"]
									}, -- end of [1]
								}, -- end of ["tasks"]
							}, -- end of ["params"]
						}, -- end of ["task"]
					}, -- end of [2]
				}, 
			} 
		} 
	}

	-- replace whole mission
	unitGroup:getController():setTask(mission)
    
    return true
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu and help
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Build the initial radio menu
function veafMove.buildRadioMenu()
    veafMove.rootPath = missionCommands.addSubMenu(veafMove.RadioMenuName, veaf.radioMenuPath)
    missionCommands.addCommand("HELP", veafMove.rootPath, veafMove.help)
end

function veafMove.help()
    local text = 
        'Create a marker and type "veaf move <group|tanker>, name <groupname> " in the text\n' ..
        'This will issue a move command to the specified group in the DCS world\n' ..
        'Type "veaf move group, name [groupname]" to move the specified group to the marker point\n' ..
        '     add ", speed [speed]" to make the group move and at the specified speed (in knots)\n' ..
        'Type "veaf move tanker, name [groupname]" to create a new tanker flight plan and move the specified tanker.\n' ..
        '     add ", speed [speed]" to make the tanker move and execute its refuel mission at the specified speed (in knots)\n' ..
        '     add ", hdg [heading]" to specify the refuel leg heading (from the marker point, in degrees)\n' ..
        '     add ", dist [distance]" to specify the refuel leg length (from the marker point, in nautical miles)\n' ..
        '     add ", alt [altitude]" to specify the refuel leg altitude (in feet)'
    trigger.action.outText(text, 30)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafMove.initialize()
    veafMove.buildRadioMenu()
    veafMarkers.registerEventHandler(veafMarkers.MarkerChange, veafMove.onEventMarkChange)
end

veafMove.logInfo(string.format("Loading version %s", veafMove.Version))


