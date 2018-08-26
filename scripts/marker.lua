------------------------------------------------------------------------------
-- marker_command.lua
-- use markers on map to move units on
-- namespace: "marker"
-- documentation: see doc/marker.md
------------------------------------------------------------------------------

marker = {}

-- a simple flag, set markerDebug = true
marker.debug = false

------------------------------------------------------------------------------
-- marker.moveAction
-- @param string groupName the group name to move on
-- @param float toPositionX
-- @param float toPositionY
-- @param float speed in knots
------------------------------------------------------------------------------
function marker.moveAction(groupName, toPositionX, toPositionY, speed)

	local unitGroup = Group.getByName(groupName)
	if unitGroup == nil then
		trigger.action.outText(groupName .. ' not found for MOVE tasking' , 10)
		return
	end
	
	-- new route point
	local newWaypoint = {
		["action"] = "Turning Point",
		["alt"] = 0,
		["alt_type"] = "BARO",
		["form"] = "Turning Point",
		["speed"] = speed/1.94384,  -- speed in m/s
		["type"] = "Turning Point",
		["x"] = toPositionX,
		["y"] = toPositionY,
	}

	-- prepare LatLong message
	local vec3={x=toPositionY, y=0, z=toPositionY}
	lat, lon = coord.LOtoLL(vec3)
	llString = mist.tostringLL(lat, lon, 2)
	
	-- order group to new waypoint
	mist.goRoute(groupName, {newWaypoint})
	
	-- and advise players that the group is moving to a new position
	trigger.action.outText(groupName .. ' moving to ' .. llString .. ' at speed ' .. speed .. ' kts' , 10)
end

------------------------------------------------------------------------------
-- marker.moveCommandEventHandler
-- ingame marker command: MOVE(groupName,speed)
-- 
-- ex ingame: MOVE(CVN,10)
------------------------------------------------------------------------------
function marker.moveCommandEventHandler(event)

	-- parse the command: MOVE(groupName,speed)
	-- params[1]: MOVE
	-- params[2]: groupName
	-- params[3]: speed

	local params = {
		[1]=nil,
		[2]=nil,
		[3]=20,   -- default speed in knots
	}
	
	local iparam = 1
	for v in string.gmatch(event.text, '([^,\(\)]+)') do
		params[iparam] = v
		iparam = iparam + 1
	end
	
	local command=params[1]
	local groupName=params[2]
	local speed=params[3]

	-- not really a MOVE command ?
	if command ~= "MOVE" then
		-- just exit, skipping this event
		return
	end

	marker.moveAction(groupName,event.pos.z, event.pos.x, speed)

end

------------------------------------------------------------------------------
-- marker.tankerAction
-- @param string groupName 
-- @param float fromPositionX
-- @param float fromPositionY
-- @param float speed in knots
-- @param float hdg heading (0-359)
-- @param float distance in Nm
-- @param float alt in feet
-- ex: marker.tankerAction("RED-Tanker ARCO", -198019, 578648, 320, 0 , 30, 20000)
------------------------------------------------------------------------------
function marker.tankerAction(groupName, fromPositionX, fromPositionY, speed, hdg ,distance,alt)

	local unitGroup = Group.getByName(groupName)
	if unitGroup == nil then
		trigger.action.outText(groupName .. ' not found for TANKER tasking' , 10)
		return
	end

	-- prepare LatLong message
	local fromVec3={x=fromPositionX, y=0, z=fromPositionY}
	lat, lon = coord.LOtoLL(fromVec3)
	fromllString = mist.tostringLL(lat, lon, 2)

	-- starting position
	local fromPosition = {
		["x"] = fromPositionX,
		["y"] = fromPositionY,
	}
	
	-- ending position
	local toPosition = {
		["x"] = fromPositionX + distance * 1000 * 0.539957 * math.cos(mist.utils.toRadian(hdg)),
		["y"] = fromPositionY + distance * 1000 * 0.539957 * math.sin(mist.utils.toRadian(hdg)),
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
						["type"] = "Turning Poin t",
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
	
	trigger.action.outText(groupName .. ' starting tanker mission ' .. fromllString .. ' hdg ' .. hdg .. ', distance ' .. distance .. ' Nm ' .. alt .. ' ft, speed ' .. math.floor(speed) .. ' knots' , 10)

end

------------------------------------------------------------------------------
-- marker.tankerCommandEventHandler
-- ingame marker command: TANKER(groupName,speed,hdg,distance,alt)
-- ex ingame: TANKER(ARCO)
-- ex ingame: TANKER(ARCO,320)
-- ex ingame: TANKER(ARCO,320,270)
-- ex ingame: TANKER(ARCO,320,90,25)
-- ex ingame: TANKER(RED-Tanker ARCO,320,0,30,20000)
------------------------------------------------------------------------------
function marker.tankerCommandEventHandler(event)

	-- parse the command: TANKER(groupName,speed,hdg,distance,alt)
	-- params[1]: TANKER
	-- params[2]: groupName
	-- params[3]: speed
	-- params[3]: hdg
	-- params[3]: distance
	-- params[3]: alt
	local params = {
		[1]=nil,
		[2]=nil,
		[3]=320,   -- in knots
		[4]=0,     -- in degrees 0-359
		[5]=20,    -- in Nm
		[6]=20000, -- in feet
	}
	
	local iparam = 1
	for v in string.gmatch(event.text, '([^,\(\)]+)') do
		params[iparam] = v
		iparam = iparam + 1
	end
	
	local command=params[1]
	local groupName=params[2]
	local speed=params[3]
	local hdg=params[4]
	local distance=params[5]
	local alt=params[6]
	
	-- not really a TANKER command ?
	if command ~= "TANKER" then
		-- just exit, skipping this event
		return
	end

	marker.tankerAction(groupName,event.pos.z, event.pos.x, speed, hdg, distance, alt)

end

------------------------------------------------------------------------------
-- markerDebugEvent
-- @param Event event : the marker event
-- display debug informations about this marker event
------------------------------------------------------------------------------
function marker.debugEvent(event)
	local vec3={x=event.pos.z, y=event.pos.y, z=event.pos.x}

	local mgrs = coord.LLtoMGRS(coord.LOtoLL(vec3))
	local mgrsString = mist.tostringMGRS(mgrs, 3)   

	lat, lon = coord.LOtoLL(vec3)
	local llString = mist.tostringLL(lat, lon, 2)

	-- display debug information
	msg='Marker changed: \'' .. event.text ..'\' on this position \n' 
		.. 'LL: '.. llString .. '\n'
		.. 'UTM: '.. mgrsString
	trigger.action.outText(msg, 10)
end

------------------------------------------------------------------------------
-- markerDetectMarkers
-- the entry point for marker events
------------------------------------------------------------------------------
function marker.detectMarkers(event)

	-- if a marker has changed
	if event.id == world.event.S_EVENT_MARK_CHANGE then 
   
		-- display debug information
		if marker.debug then
			marker.debugEvent(event)
		end

		-- handle MOVE command (need to be improved)
		if event.text~=nil and event.text:find('MOVE') then
			marker.moveCommandEventHandler(event)			
		end 

		-- handle TANKER command (need to be improved)
		if event.text~=nil and event.text:find('TANKER') then
			marker.tankerCommandEventHandler(event)			
		end 
		
	end 
end 

-- in case of testing, remove first previous handlers
mist.removeEventHandler(markerDetectMarkersEventHandler)

-- init markers event handlers
markerDetectMarkersEventHandler=mist.addEventHandler(marker.detectMarkers) 
