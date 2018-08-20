------------------------------------------------------------------------------
-- VEAF_build_grass_runway
-- Build a grass runway from
-- @param runwayOrigin a static unit object (right side)
-- @return nil
------------------------------------------------------------------------------
function VEAF_build_grass_runway(runwayOrigin)

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
		x = runwayOrigin.x + width * math.cos(mist.utils.toRadian(angle-90)),
		y = runwayOrigin.y + width * math.sin(mist.utils.toRadian(angle-90)),
	}

    local template = {
	    category = runwayOrigin.category,
        categoryStatic = runwayOrigin.categoryStatic,
        coalition = runwayOrigin.coalition,
        country = runwayOrigin.country,
        countryId = runwayOrigin.countryId,
        heading = runwayOrigin.heading,
        shape_name =  runwayOrigin.shape_name,
        type = runwayOrigin.type,
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
-- VEAF_build_grass_runways
-- Build all grass runway from static object like 'GRASS RUNWAY'
-- @return nil
------------------------------------------------------------------------------
function VEAF_build_grass_runways()

	for name, unit in pairs(mist.DBs.unitsByName) do
		if string.find(string.lower(name), string.lower('veafgr')) then		
            VEAF_build_grass_runway(unit)
        end
	end
end

------------------------------------------------------------------------------
-- on load - build all tagged 'veafgr' as grass runways
-- @return nil
------------------------------------------------------------------------------
VEAF_build_grass_runways()
