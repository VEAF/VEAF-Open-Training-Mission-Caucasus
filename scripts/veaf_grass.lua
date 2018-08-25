------------------------------------------------------------------------------
-- script to build units on FARPS and grass runways
------------------------------------------------------------------------------

veafGrass = {}

------------------------------------------------------------------------------
-- veafGrass.buildGrassRunway
-- Build a grass runway from runwayOrigin
-- @param runwayOrigin a static unit object (right side)
-- @return nil
------------------------------------------------------------------------------
function veafGrass.buildGrassRunway(runwayOrigin)

	-- runway length in meters
	local length = 600;
	-- a plot each XX meters
	local space = 50;
	-- runway width XX meters
	local width = 30;
	
	-- nb plots
	local nbPlots = math.ceil(length / space);

	local angle = mist.utils.toDegree(runwayOrigin.heading);

	-- create left origin from right origin
	local leftOrigin = {
		["x"] = runwayOrigin.x + width * math.cos(mist.utils.toRadian(angle-90)),
		["y"] = runwayOrigin.y + width * math.sin(mist.utils.toRadian(angle-90)),
	}

    local template = {
	    ["category"] = runwayOrigin.category,
        ["categoryStatic"] = runwayOrigin.categoryStatic,
        ["coalition"] = runwayOrigin.coalition,
        ["country"] = runwayOrigin.country,
        ["countryId"] = runwayOrigin.countryId,
        ["heading"] = runwayOrigin.heading,
        ["shape_name"] =  runwayOrigin.shape_name,
        ["type"] = runwayOrigin.type,
	}
	
	-- leftOrigin plot
	local leftOriginPlot = mist.utils.deepCopy(template)
	leftOriginPlot.x = leftOrigin.x
	leftOriginPlot.y = leftOrigin.y
	mist.dynAddStatic(leftOriginPlot)
	
	-- place plots
	for i = 1, nbPlots do
		-- right plot
		local leftPlot = mist.utils.deepCopy(template)
		leftPlot.x = runwayOrigin.x + i * space * math.cos(mist.utils.toRadian(angle))
		leftPlot.y = runwayOrigin.y + i * space * math.sin(mist.utils.toRadian(angle))
        mist.dynAddStatic(leftPlot)
		
		-- right plot
		local rightPlot = mist.utils.deepCopy(template)
		rightPlot.x = leftOrigin.x + i * space * math.cos(mist.utils.toRadian(angle))
		rightPlot.y = leftOrigin.y + i * space * math.sin(mist.utils.toRadian(angle))
        mist.dynAddStatic(rightPlot)
		
	end
end

------------------------------------------------------------------------------
-- veafGrass.buildGrassRunways
-- Build all grass runway from static object like 'GRASS_RUNWAY'
-- @return nil
------------------------------------------------------------------------------
function veafGrass.buildGrassRunways()

	for name, unit in pairs(mist.DBs.unitsByName) do
		if string.find(name, 'GRASS_RUNWAY') then		
            veafGrass.buildGrassRunway(unit)
        end
	end
end

------------------------------------------------------------------------------
-- veafGrass.buildFarpsUnits
-- build FARP units on FARP with group name like "FARP "
------------------------------------------------------------------------------
function veafGrass.buildFarpsUnits()

	for name, unit in pairs(mist.DBs.unitsByName) do
		if unit.type == "SINGLE_HELIPAD" and string.find(name, 'FARP ') then		
			veafGrass.buildFarpUnits(unit, 100)
		elseif unit.type == "FARP" and string.find(name, 'FARP ') then		
			veafGrass.buildFarpUnits(unit, 140)
		end
	end
	
end

------------------------------------------------------------------------------
-- build nice FARP units arround the FARP
-- @param float tentDistance distance (in meters) from the center of the FARP 
-- to first tent
------------------------------------------------------------------------------
function veafGrass.buildFarpUnits(farp, tentDistance)

	local angle = mist.utils.toDegree(farp.heading);
	local tentSpacing=20
	local tentOrigin = {
		["x"] = farp.x + tentDistance * math.cos(mist.utils.toRadian(angle)),
		["y"] = farp.y + tentDistance * math.sin(mist.utils.toRadian(angle)),
	}

	-- create tents
	for j = 1,2 do
		for i = 1,3 do
			local tent = {
				["category"] = 'static',
				["categoryStatic"] = 'Fortifications',
				["coalition"] = farp.coalition,
				["country"] = farp.country,
				["countryId"] = farp.countryId,
				["heading"] = mist.utils.toRadian(angle-90),
				["type"] = 'FARP Tent',
				["x"] = tentOrigin.x + (i-1) * tentSpacing * math.cos(mist.utils.toRadian(angle)) - (j-1) * tentSpacing * math.sin(mist.utils.toRadian(angle)),
				["y"] = tentOrigin.y + (i-1) * tentSpacing * math.sin(mist.utils.toRadian(angle)) + (j-1) * tentSpacing *  math.cos(mist.utils.toRadian(angle)),
			}
			
			mist.dynAddStatic(tent)
			
		end	
	end
	
	-- spawn other static units
	local otherUnits={
		'FARP Fuel Depot',
		'FARP Ammo Dump Coating',
		'GeneratorF',
	}
	local otherSpacing=15
	local otherDistance=tentDistance-otherSpacing
	local otherOrigin = {
		["x"] = farp.x + otherDistance * math.cos(mist.utils.toRadian(angle)),
		["y"] = farp.y + otherDistance * math.sin(mist.utils.toRadian(angle)),
	}
	
	for j,typeName in ipairs(otherUnits) do
		local otherUnit = {
			["category"] = 'static',
			["categoryStatic"] = 'Fortifications',
			["coalition"] = farp.coalition,
			["country"] = farp.country,
			["countryId"] = farp.countryId,
			["heading"] = mist.utils.toRadian(angle-90),
			["type"] = typeName,
			["x"] = otherOrigin.x - (j-1) * otherSpacing * math.sin(mist.utils.toRadian(angle)),
			["y"] = otherOrigin.y + (j-1) * otherSpacing * math.cos(mist.utils.toRadian(angle)),
		}		
		mist.dynAddStatic(otherUnit)
	end

	-- create Windsock
	local windstockDistance = 50
	local windstockAngle = 45
	local windstockUnit = {
		["category"] = 'static',
		["categoryStatic"] = 'Fortifications',
		["coalition"] = farp.coalition,
		["country"] = farp.country,
		["countryId"] = farp.countryId,
		["heading"] = mist.utils.toRadian(angle-90),
		["type"] = 'H-Windsock_RW',
		["x"] = farp.x + windstockDistance * math.cos(mist.utils.toRadian(angle+windstockAngle)),
		["y"] = farp.y + windstockDistance * math.sin(mist.utils.toRadian(angle+windstockAngle)),
	}
	mist.dynAddStatic(windstockUnit)

	-- spawn a FARP escort group
	local farpEscortUnitsNames={
		blue = {
			"Hummer",
			"M978 HEMTT Tanker",
			"M978 HEMTT Tanker",
			"HEMTT TFFT",
			"HEMTT TFFT",
			"Hummer",
		},		
		red = {
			"ATZ-10",
			"ATZ-10",
			"Ural-4320 APA-5D",
			"Ural-375",
			"Ural-375",
			"Ural-375 PBU",
		}
	}

	local unitsSpacing=6
	local unitsDistance=otherDistance-20;
	local unitsOrigin = {
		x = farp.x + unitsDistance * math.cos(mist.utils.toRadian(angle)),
		y = farp.y + unitsDistance * math.sin(mist.utils.toRadian(angle)),
	}
	
	local farpEscortGroup = {
		["category"] = 'vehicle',
		["coalition"] = farp.coalition,
		["country"] = farp.country,
		["countryId"] = farp.countryId,
		["groupName"] = farp.groupName .. ' escort',
		["units"] = {},
	}		
	for j,typeName in ipairs(farpEscortUnitsNames[farp.coalition]) do
		local escrotUnit = {
			["heading"] = mist.utils.toRadian(angle-135), -- parked \\\\\
			["type"] = typeName,
			["x"] = unitsOrigin.x - (j-1) * unitsSpacing * math.sin(mist.utils.toRadian(angle)),
			["y"] = unitsOrigin.y + (j-1) * unitsSpacing * math.cos(mist.utils.toRadian(angle)),
			["skill"] = "Random",
		}		
		table.insert(farpEscortGroup.units, escrotUnit)

	end

	mist.dynAdd(farpEscortGroup)
	
end

-- to auto generate FARP units, add EXECUTION SCRIPT after this script is loaded
-- veafGrass.buildFarpsUnits()
-- veafGrass.buildGrassRunways()
