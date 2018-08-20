-- CAS Infinity 1.12 transport.dll crash fix attempt, turning disperse under fire off

--- casInfinity Table.
casInfinity={}

--- Enable debug mode ==> give more output to DCS log file.
casInfinity.Debug=true

groundAssaultWave = 0
enemyFighterCount = 0
groupAliveCheckTaskID = 'none'
smokeResetTaskID = 'none'
flareResetID = 'none'

averageGroupPosition = 0

--- Debug output to dcs.log file.
function casInfinity.info(text)
  if casInfinity.Debug then
    env.info(text)
  end
end

function MA_buildMenu()
	_taskingsRootPath = missionCommands.addSubMenu('Tasking')
	
	_taskingsGroundPath = missionCommands.addSubMenu('Ground', _taskingsRootPath)
	missionCommands.addCommand('INFO - Request a CAS task', _taskingsGroundPath, MA_infoCreateTask)
	_taskingsTransportPath = missionCommands.addSubMenu('Transport', _taskingsRootPath)
	
	missionCommands.addCommand('Request cargo load', _taskingsTransportPath, MA_createTransportTask1)
end


-- Transport Tasks

function MA_createTransportTask1()
	--missionCommands.removeItem({'Tasking', 'Transport', 'Request cargo load'})
	MA_out('Copy new cargo requested, stand by...', 10)

	mist.scheduleFunction(MA_createTransportTask2, {}, timer.getTime() + 10 + mist.random(50))
end

function MA_createTransportTask2()
	--local zoneName = 'Heli Cargo #00' .. mist.random(5)
	local zoneName = 'Heli Cargo #001'
	local zone = trigger.misc.getZone(zoneName)
	
	repeat --Find a random spot of LAND within the large AO zone
		cargoSpawnZone = mist.getRandPointInCircle(zone.point, zone.radius)
  until (land.getSurfaceType(unitPosition) == land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY) 
	
	local cargo = {}
	local cargoRand
	local cargoType
	local cargoWeight = 0
	
	-- rand cargo
	cargoRand = mist.random(8)
	
	if cargoRand == 1 then
		cargoType = 'ammo_cargo'
		cargoWeight = math.random(2205, 3000)
	elseif cargoRand == 2 then
		cargoType = 'barrels_cargo'
		cargoWeight = math.random(300, 1058)
	elseif cargoRand == 3 then
		cargoType = 'container_cargo'
		cargoWeight = math.random(300, 3000)
	elseif cargoRand == 4 then
		cargoType = 'f_bar_cargo'
		cargoWeight = 0
	elseif cargoRand == 5 then
		cargoType = 'fueltank_cargo'
		cargoWeight = math.random(1764, 3000)
	elseif cargoRand == 6 then
		cargoType = 'm117_cargo'
		cargoWeight = 0
	elseif cargoRand == 7 then
		cargoType = 'oiltank_cargo'
		cargoWeight = math.random(1543, 3000)
	elseif cargoRand == 8 then
		cargoType = 'uh1h_cargo'
		cargoWeight = math.random(220, 3000)
	end
	
	local cargoTable = {
		type = cargoType,
		country = 'USA',
		category = 'Cargos',
		name = cargoType,
		x = cargoSpawnZone.x,
		y = cargoSpawnZone.y,
		canCargo = true
	}
	
	if cargoWeight > 0 then
		table.insert(cargoTable, {mass = cargoWeight})
	end
	
	mist.dynAddStatic(cargoTable)
	
	MA_out('New cargo ready', 10)
	MA_out('Mass : ' .. cargoWeight, 10)
	
end

-- CAS tasks

function MA_infoCreateTask()
    trigger.action.outText("Create a marker and use the 'create ao' command ; parameters are comma-separated and can be : size, sam, armor, spacing" , 10)
end

function MA_createTask2(unitSpawnZone, size, sam, armor, spacing)

		local units = {}
		local infantryUnits = {}
		local groupSize
		local i
		
		-- Move reaper
		
		local groupName = 'Reaper'

    -- new route point
    local newWaypoint = {
      action = "Turning Point",
      alt = 20000,
      alt_type = "BARO",
      form = "Turning Point",
      speed = 61,
      type = "Turning Point",
      x = unitSpawnZone.x,
      y = unitSpawnZone.y
    }
    
    -- prepare LatLong message
    local vec3={x=unitSpawnZone.x, y=unitSpawnZone.y, z=unitSpawnZone.z}
    lat, lon = coord.LOtoLL(vec3)
    llString = mist.tostringLL(lat, lon, 2)
    
    -- order group to new waypoint
    mist.goRoute(groupName, {newWaypoint})
    
    casInfinity.info(groupName .. ' moving to ' .. llString .. ' at 120 knots')
		
		-- Insert Manpads
		local iglaCount = 0
		if sam > 0 then
			local iglaRand = mist.random(100)
			
			if iglaRand > 100-(5*sam) then
				iglaCount = mist.random(1.5 * size, 2 * size)
			elseif iglaRand > 100-(5+10*sam) then
				iglaCount = mist.random(1.25 * size, 1.5 * size)
			elseif iglaRand > 100-(15+15*sam) then
				iglaCount = mist.random(1 * size, 1.25 * size)
			elseif iglaRand > 100-(45+25*sam) then
				iglaCount = mist.random(size/2, size)
			else
				iglaCount = mist.random(size/2)
			end
		  iglaCount = math.floor(iglaCount)
		end
		
		casInfinity.info(string.format("iglaCount = %d", iglaCount))
		
		if iglaCount > 0 then
			
			for i = 1, iglaCount do
				
        repeat --Place every unit within a (size-2+spacing)*400ft radius circle from the spot previously randomly chosen
          unitPosition = mist.getRandPointInCircle(unitSpawnZone, (size-2+spacing)*200)
        until (land.getSurfaceType(unitPosition) == land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY) 

				table.insert(infantryUnits,
				{
					["x"] = unitPosition.x,
					["y"] = unitPosition.y,
					["type"] = 'SA-18 Igla-S manpad',
					["name"] = 'Red Target Manpad Group Unit ' .. i,
					["heading"] = 0,
					["skill"] = "Random"
				})
				
				table.insert(infantryUnits,
				{
					["x"] = unitPosition.x-3,
					["y"] = unitPosition.y,
					["type"] = 'SA-18 Igla-S comm',
					["name"] = 'Red Target Manpad comm Group Unit ' .. i,
					["heading"] = 0,
					["skill"] = "Random"
				})
				
			end
			
		end
		
		-- Insert SAMs
		local samCount  = 0
		if sam > 0 then
			local samRand = mist.random(100)
			if samRand > 100-(5*sam) then
				samCount = mist.random(2.5 * size, 3 * size)
			elseif samRand > 100-(5+10*sam) then
				samCount = mist.random(2 * size, 2.5 * size)
			elseif samRand > 100-(15+15*sam) then
				samCount = mist.random(1.5 * size, 2 * size)
			elseif samRand > 100-(45+25*sam) then
				samCount = mist.random(size, 1.5 * size)
			else
				samCount = mist.random(size)
			end
	    samCount= math.floor(samCount)
		end
		
		casInfinity.info(string.format("samCount = %d", samCount))

		if samCount > 0 then
			
			for i = 1, samCount do
				
				local samTypeRand = mist.random(100)
				
				if samTypeRand > (98-(3*(sam-1))) then
					samType = 'Tor 9A331'
				elseif samTypeRand > (94-(4*(sam-1))) then
					samType = '2S6 Tunguska'
				elseif samTypeRand > (86-(4*(sam-1))) then
					samType = 'Osa 9A33 ln'
				elseif samTypeRand > (70-(5*(sam-1))) then
					samType = 'Strela-10M3'
				elseif samTypeRand > (50-(5*(sam-1))) then
					samType = 'Strela-1 9P31'
				elseif samTypeRand > (25-(5*(sam-1))) then
					samType = 'ZSU-23-4 Shilka'
				else
					samType = 'Ural-375 ZU-23'
				end
				
				casInfinity.info(string.format("samType = %s", samType))
				
				repeat --Place every unit within a (size-2+spacing)*400ft radius circle from the spot previously randomly chosen
					unitPosition = mist.getRandPointInCircle(unitSpawnZone, (size-2+spacing)*200)
				until (land.getSurfaceType(unitPosition) == land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY)

				table.insert(units,
				{
					["x"] = unitPosition.x,
					["y"] = unitPosition.y,
					["type"] = samType,
					["name"] = 'Red Target SAM Group Unit ' .. i,
					["heading"] = 0,
					["skill"] = "Random"
				})
				
			end
			
		end
		
		groupSize = samCount
		
		-- Insert armors
		local armorCount = 0
		if armor > 0 then
		
			armorCount = mist.random(3,8) * size

			local armorType
			local armorRand
			
			for i = 1, armorCount do --Insert a random number (min 1, max 5)of random (selection 14 possible) vehicles into table units{}
				
				if armor == 1 then
					armorRand = mist.random(4)
					if armorRand == 1 then
						armorType = 'BTR-80'
					elseif armorRand == 2 then
						armorType = 'MTLB'
					elseif armorRand == 3 then
						armorType = 'BRDM-2'
					elseif armorRand == 4 then
						armorType = 'Boman'
					end
				elseif armor == 2 then
					armorRand = mist.random(7)
					if armorRand == 1 then
						armorType = 'BTR-80'
					elseif armorRand == 2 then
						armorType = 'MTLB'
					elseif armorRand == 3 then
						armorType = 'BRDM-2'
					elseif armorRand == 4 then
						armorType = 'BTR_D'
					elseif armorRand == 5 then
						armorType = 'Boman'
					elseif armorRand == 6 then
						armorType = 'BMD-1'
					elseif armorRand == 7 then
						armorType = 'BMP-1'
					end
				elseif armor == 3 then
					armorRand = mist.random(5)
					if armorRand == 1 then
						armorType = 'BTR-80'
					elseif armorRand == 2 then
						armorType = 'BRDM-2'
					elseif armorRand == 3 then
						armorType = 'BMD-1'
					elseif armorRand == 4 then
						armorType = 'BMP-1'
					elseif armorRand == 5 then
						armorType = 'BMP-2'
					end
				elseif armor == 4 then
					armorRand = mist.random(8)
					if armorRand == 1 then
						armorType = 'BTR-80'
					elseif armorRand == 2 then
						armorType = 'Boman'
					elseif armorRand == 3 then
						armorType = 'BMD-1'
					elseif armorRand == 4 then
						armorType = 'BMP-1'
					elseif armorRand == 5 then
						armorType = 'BMP-2'
					elseif armorRand == 6 then
						armorType = 'BMP-3'
					elseif armorRand == 7 then
						armorType = 'T-55'
					elseif armorRand == 8 then
						armorType = 'T-72B'
					end
				elseif armor >= 5 then
					armorRand = mist.random(6)
					if armorRand == 1 then
						armorType = 'BTR_D'
					elseif armorRand == 2 then
						armorType = 'BMP-2'
					elseif armorRand == 3 then
						armorType = 'BMP-3'
					elseif armorRand == 4 then
						armorType = 'T-72B'
					elseif armorRand == 5 then
						armorType = 'T-80UD'
					elseif armorRand == 6 then
						armorType = 'T-90'
					end
				end
				
        repeat --Place every unit within a (size-2+spacing)*400ft radius circle from the spot previously randomly chosen
          unitPosition = mist.getRandPointInCircle(unitSpawnZone, (size-2+spacing)*200)
				until (land.getSurfaceType(unitPosition) == land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY) 

				table.insert(units,
				{
					["x"] = unitPosition.x,
					["y"] = unitPosition.y,
					["type"] = armorType,
					["name"] = 'Red Target Armor Group Unit ' .. i,
					["heading"] = 0,
					["skill"] = "Random"
				})
				
			end
		end
		
		casInfinity.info(string.format("armorCount = %d", armorCount))

		groupSize = groupSize + armorCount
		
		-- Insert transport
		local transportCount = mist.random(3,8) * size
		transportCount = math.floor(transportCount)
		
		local transportType
		
		for i = 1, transportCount do --Insert a random number (min 1, max 5)of random (selection 14 possible) vehicles into table units{}
				
			local transportRand = mist.random(14)
		
			if transportRand == 1 then
				transportType = 'Ural-4320 APA-5D'
				--transportType = 'Tigr_233036'
			elseif transportRand == 2 then
				transportType = 'ATMZ-5'
			elseif transportRand == 3 then
				transportType = 'Ural-4320 APA-5D'
			elseif transportRand == 4 then
				transportType = 'ZiL-131 APA-80'
			elseif transportRand == 5 then
				transportType = 'GAZ-3308'
			elseif transportRand == 6 then
				transportType = 'GAZ-66'
			elseif transportRand == 7 then
				transportType = 'KAMAZ Truck'
			elseif transportRand == 8 then
				transportType = 'UAZ-469'
			elseif transportRand == 9 then
				transportType = 'Ural-375'
			elseif transportRand == 10 then
				transportType = 'Ural-4320-31'
			elseif transportRand == 11 then
				transportType = 'Ural-4320T'
			elseif transportRand == 12 then
				transportType = 'ZIL-131 KUNG'
			elseif transportRand == 13 then
				transportType = 'Ural ATsP-6'
			end

        repeat --Place every unit within a (size-2+spacing)*400ft radius circle from the spot previously randomly chosen
          unitPosition = mist.getRandPointInCircle(unitSpawnZone, (size-2+spacing)*200)
			until (land.getSurfaceType(unitPosition) == land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY)

			table.insert(units,
			{
				["x"] = unitPosition.x,
				["y"] = unitPosition.y,
				["type"] = transportType,
				["name"] = 'Red Target Transport Group Unit ' .. i,
				["heading"] = 0,
				["skill"] = "Random"
			})
			
		end
		
		casInfinity.info(string.format("transportCount = %d", transportCount))

		groupSize = groupSize + transportCount
		
		-- insert infantry
		local infantryCount = mist.random(groupSize/10, groupSize)
		infantryCount = math.floor(infantryCount)
		
		for i = 1, infantryCount do --Insert 0.1 to 1 times as many infantry soldiers as there are vehicles in the group into the table units{}
		
			unitType = 'Soldier AK'
		
        repeat --Place every unit within a (size-2+spacing)*400ft radius circle from the spot previously randomly chosen
          unitPosition = mist.getRandPointInCircle(unitSpawnZone, (size-2+spacing)*200)
			until (land.getSurfaceType(unitPosition) == land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY)
		
			table.insert(infantryUnits,
				{
					["x"] = unitPosition.x,
					["y"] = unitPosition.y,
					["type"] = unitType,
					["name"] = 'Red Target Group Unit ' .. groupSize+i,
					["heading"] = 0,
					["skill"] = "Random"
				})
		
		end
		
		casInfinity.info(string.format("infantryCount = %d", infantryCount))

		env.info('spawns counter')
		env.info('SAMs : ' .. samCount)
		env.info('Armor : ' .. iglaCount)
		env.info('Transport : ' .. transportCount)
		
		--Create and spawn groups
		mist.dynAdd({country = 'RUSSIA', category = 'GROUND_UNIT', name = 'Red Target Group', hidden = false, units = units })
		mist.dynAdd({country = 'RUSSIA', category = 'GROUND_UNIT', name = 'Red Infantry Target Group', hidden = false, units = infantryUnits }) 
		
		-- get groups controller
		local SpawnedGroupController = Group.getByName('Red Target Group'):getController()
		local SpawnedInfantryGroupController = Group.getByName('Red Infantry Target Group'):getController()
		
		-- set alarm state to red
		SpawnedGroupController:setOption(9, 2)
		SpawnedInfantryGroupController:setOption(9, 2)
		
		--SpawnedGroupController:setOption(8, false)
		--SpawnedInfantryGroupController:setOption(8, false)
		SpawnedGroupController:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, false)
		SpawnedInfantryGroupController:setOption(AI.Option.Ground.id.DISPERSE_ON_ATTACK, false)
		
		--Controller.setOption(_controller, AI.Option.Ground.id.DISPERSE_ON_ATTACK, false)  template
		
		averageGroupPosition = MA_getAvgPos('Red Target Group')
		
		--Code to notify the clients of the new objective MGRS grid location. A message is displayed, and also added to F10 menu for continuous review
		mgrs = coord.LLtoMGRS(coord.LOtoLL(unitSpawnZone))
		mgrsString = mist.tostringMGRS(mgrs, 3)
		
		lat, lon = coord.LOtoLL(unitSpawnZone)
		llString = mist.tostringLL(lat, lon, 2)
		brString = MA_getBearingRange()
		--unitSpawnZone3d = {unitSpawnZone.x, land.getHeight(unitSpawnZone)+5, unitSpawnZone.y}
		--windVec = atmosphere.getWind(unitSpawnZone3d)
		
		--env.info(('windVec : ' .. windVec.x .. ' / ' .. windVec.y .. ' / ' .. windVec.z))
		
		
		-- getwind() test
		--local unit_posit = Unit.getByName('Red Target Transport Group Unit 1'):getPosition().p
		--local atmo_wind = atmosphere.getWind(unit_posit)
		

		_targetInfoPath = missionCommands.addSubMenu('Target information', _taskingsGroundPath)
		
		missionCommands.addCommand('TARGET: Group of ' .. groupSize .. ' vehicles and infantry.', _targetInfoPath, MA_emptyFunction)
		missionCommands.addCommand('LAT LON: ' .. llString .. '.', _targetInfoPath, MA_emptyFunction)
		missionCommands.addCommand('MGRS/UTM: ' .. mgrsString .. '.', _targetInfoPath, MA_emptyFunction)
		missionCommands.addCommand(brString, _targetInfoPath, MA_emptyFunction)
		
		--missionCommands.addCommand('Height: ' .. land.getHeight(unitSpawnZone),  _targetInfoPath, MA_emptyFunction)
		
		
		-- getWind() test
		--missionCommands.addCommand('windVec : ' .. windVec.x .. ' / ' .. windVec.y .. ' / ' .. windVec.z,  _targetInfoPath, MA_emptyFunction)
		--missionCommands.addCommand('atmo_wind : ' .. atmo_wind.x .. ' / ' .. atmo_wind.y .. ' / ' .. atmo_wind.z,  _targetInfoPath, MA_emptyFunction)
		--trigger.action.outText(string.format("Wind x: %d, y: %d, z: %d", atmo_wind.x, atmo_wind.y, atmo_wind.z), 100)
		
		
		_targetMarkersPath = missionCommands.addSubMenu('Target markers', _taskingsGroundPath)
		missionCommands.addCommand('Request smoke on target area', _targetMarkersPath, MA_smokeRequested)
		missionCommands.addCommand('Request illumination flare over target area', _targetMarkersPath, MA_illBombRequested)


		missionCommands.addCommand('Skip current objective', _taskingsGroundPath, MA_skipTask)
		missionCommands.removeItem({'Tasking', 'Ground', 'INFO - Request a CAS task'})
		
		MA_out('An enemy group of ' .. groupSize .. ' vehicles and infantry has been located. Consult your F10 radio commands for more information.', 5)
		
		groupAliveCheckTaskID = mist.scheduleFunction(MA_groundGroupAliveCheck,{},timer.getTime()+5)	
end


function MA_groundGroupAliveCheck()

	local groupName = 'Red Target Group'
	if Group.getByName(groupName) and Group.getByName(groupName):isExist() == true and #Group.getByName(groupName):getUnits() > 0 then
		groupAliveCheckTaskID = mist.scheduleFunction(MA_groundGroupAliveCheck,{},timer.getTime()+5)
	else
		MA_taskCompleted()
	end
	
end


function MA_getBearingRange()

	local avgPos = MA_getAvgPos('Red Target Group')
	local ref = mist.utils.makeVec3(mist.DBs.missionData.bullseye.blue, 0)
	
	local vec = {x = avgPos.x - ref.x, y = avgPos.y - ref.y, z = avgPos.z - ref.z}
	local dir = mist.utils.round(mist.utils.toDegree(mist.utils.getDir(vec, ref)), 0)
	local dist = mist.utils.get2DDist(avgPos, ref)
	local distMetric = mist.utils.round(dist/1000, 0)
	local distImperial = mist.utils.round(mist.utils.metersToNM(dist), 0)
	
	dir = string.format('%03d', dir)
	return 'Target area: Bulls ' .. dir .. ' for ' .. distMetric .. 'km/' .. distImperial .. 'nm'

end


function MA_smokeRequested()

	local vec3pos = averageGroupPosition
	trigger.action.smoke(vec3pos, 1)
	MA_out('Copy smoke requested, RED smoke on the deck!',5)
	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers', 'Request smoke on target area'})
	missionCommands.addCommand('Target is marked with red smoke', _targetMarkersPath, MA_emptyFunction)
	smokeResetTaskID = mist.scheduleFunction(MA_smokeReset,{}, timer.getTime() + 360)

end


function MA_emptyFunction()

end


function MA_smokeReset()

	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers', 'Target is marked with red smoke'})
	missionCommands.addCommand('Request smoke on target area', _targetMarkersPath, MA_smokeRequested)
	MA_out('Smoke request is now again available',5)

end


function MA_illBombRequested()

	local vec3pos = MA_getAvgPos('Red Target Group')
	vec3pos.y = vec3pos.y + 2000
	trigger.action.illuminationBomb(vec3pos)
	MA_out('Copy illumination flare requested, illumination flare over target area!',5)
	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers', 'Request illumination flare over target area'})
	missionCommands.addCommand('Target area is marked with illumination flare', _targetMarkersPath, MA_emptyFunction)
	flareResetID = mist.scheduleFunction(MA_flareReset,{}, timer.getTime() + 300)

end


function MA_flareReset()

	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers', 'Target area is marked with illumination flare'})
	missionCommands.addCommand('Request illumination flare over target area', _targetMarkersPath, MA_illBombRequested)
	MA_out('Illumination flare request is now again available', 5)

end


function MA_getAvgPos(groupName)

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


function MA_taskCompleted()

	MA_postTaskCleanup()
	MA_out('Objective group destroyed! Use F10 menu to request new tasking.', 5)

end


function MA_skipTask()

	mist.removeFunction(groupAliveCheckTaskID)
	MA_postTaskCleanup()
	MA_out('Skipping task, cleaning up...', 5)
	mist.scheduleFunction(MA_destroySkippedGroup,{}, timer.getTime() + 7)

end


function MA_destroySkippedGroup()
	
	local targetGroup = Group.getByName('Red Target Group')
	targetGroup:destroy()
	
	MA_out('Objective skipped, cleanup complete. Use F10 menu to request new tasking.', 5)

end

function MA_postTaskCleanup()

	if smokeResetTaskID ~= 'none' then
		mist.removeFunction(smokeResetTaskID)
	end
	
	if flareResetID ~= 'none' then
		mist.removeFunction(flareResetID)
	end
	
	local targetGroup = Group.getByName('Red Infantry Target Group')
	targetGroup:destroy()
	
	missionCommands.removeItem({'Tasking', 'Ground', 'Skip current objective'})
	missionCommands.removeItem({'Tasking', 'Ground', 'Target markers'})
	missionCommands.removeItem({'Tasking', 'Ground', 'Target information'})
  missionCommands.addCommand('INFO - Request a CAS task', _taskingsGroundPath, MA_infoCreateTask)
	groupAliveCheckTaskID = 'none'

end


function MA_out(strOutText,outTime) -- function outputs text using the mist message system

	trigger.action.outText(strOutText, outTime)

end


mist.scheduleFunction(MA_buildMenu, {}, timer.getTime() + 2)


env.info(('Infinity script loaded.'))

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--Event Handler
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

--- Split string. C.f. http://stackoverflow.com/questions/1426954/split-string-in-lua
function casInfinity._split(str, sep)
  local result = {}
  local regex = ("([^%s]+)"):format(sep)
  for each in str:gmatch(regex) do
    table.insert(result, each)
  end
  return result
end

--- Extract keywords from mark text.
function casInfinity._MarkTextAnalysis(text)

  casInfinity.info(string.format("MarkTextAnalysis text:\n%s", text))
 
  -- Option parameters extracted from the mark text. 
  local switch={}
  
  -- Check for correct keywords.
  if not(text:lower():find("create ao")) then
    casInfinity.info('WARNING: create AO keyword not specified!')
    return nil
  end
    
  -- keywords are split by ","
  local keywords=casInfinity._split(text, ",")

  for _,keyphrase in pairs(keywords) do
  
    -- Split keyphrase by space. First one is the key and second, ... the parameter(s) until the next comma.
    local str=casInfinity._split(keyphrase, " ")
    local key=str[1]
    local val=str[2]
    
    if key:lower() == "size" then
      switch.size = tonumber(val)
      casInfinity.info(string.format("Keyword size = %d", val))
    elseif key:lower() == "sam" then
      switch.sam = tonumber(val)
      casInfinity.info(string.format("Keyword sam = %d", val))
    elseif key:lower() == "armor" then
      switch.armor = tonumber(val)
      casInfinity.info(string.format("Keyword armor = %d", val))
    elseif key:lower() == "spacing" then
      switch.spacing = tonumber(val)
      casInfinity.info(string.format("Keyword spacing = %d", val))
    end
    
  end
  
  return switch
end

local function AOMarker(event)
	if event.id == world.event.S_EVENT_MARK_CHANGE then
	
		casInfinity.info("Detected event")
		
		if event.text~=nil then
		
			-- Analyse the mark point text and extract the keywords.
			local _options=casInfinity._MarkTextAnalysis(event.text)

			if _options then
				casInfinity.info("Event is create AO")
			
				trigger.action.removeMark(event.idx)

				local size = 1
				local sam = 1
				local armor = 3
				local spacing = 3
				
				-- Check options set commands and return.
				if _options.size then
					size = _options.size
				end
				if _options.sam then
					sam = _options.sam
				end
				if _options.armor then
					armor = _options.armor
				end
				if _options.spacing then
					spacing = _options.spacing
				end

				if groupAliveCheckTaskID == 'none' then
				
					casInfinity.info("groupAliveCheckTaskID == 'none'")
					
					casInfinity.info(string.format("size = %s", tostring(size)))
					casInfinity.info(string.format("sam = %s", tostring(sam)))
					casInfinity.info(string.format("armor = %s", tostring(armor)))
					casInfinity.info(string.format("spacing = %s", tostring(spacing)))
					
					local vec3 = {x=event.pos.z, y=event.pos.y, z=event.pos.x, p=0}
					local unitSpawnZone = mist.utils.makeVec2(vec3)
				
					if land.getSurfaceType(unitSpawnZone) == land.SurfaceType.LAND or land.SurfaceType.LAND or land.getSurfaceType(unitPosition) == land.SurfaceType.ROAD or land.getSurfaceType(unitPosition) == land.SurfaceType.RUNWAY then
			
							MA_out('Copy new tasking requested, stand by...', 10)
							
							mist.scheduleFunction(MA_createTask2, {unitSpawnZone, size, sam, armor, spacing}, timer.getTime() + 2 + mist.random(5))
							
					else
					
						MA_out('Marker not on land, Cancelling Group !', 10)
					
					end
				else
					MA_out('CAS zone already exists !', 10)
				end
			 end
		end
	end
end	

AOMarkerEventHandler = mist.addEventHandler(AOMarker)		