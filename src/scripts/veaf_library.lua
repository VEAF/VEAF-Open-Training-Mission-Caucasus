------------------------------------------------------------------------
-- Function library for the VEAF missions
-- More infos : http://www.VEAF.org
-- last version : https://github.com/MagicBra/VEAF_misison_library
------------------------------------------------------------------------
-- Other resources and thanks : 
-- MIST  library from Grimes and Speed (http://wiki.hoggit.us/view/Mission_Scripting_Tools_Documentation)
-- Dismount script from mbot (http://forums.eagle.ru/showthread.php?t=109676)
--
-- thanks everyone of DCS community for making all the tests and reports :)
------------------------------------------------------------------------
-- initiator    : MagicBra (nosdudefr-a@t-gmail.com)
-- contributors : 
-- testers      :
------------------------------------------------------------------------
-- versions : 
-- 1.0  : + added random move between zones for a group
-- 1.01 : + added check to enable the functions 
-- 1.1  : + added automatic embark/disembark for ground units
-- 1.2  : + added automatic objectives creation in zones

------------------------------------------------------------------------------------------------------------
-- Configuration for the movement between random zones for ground units
------------------------------------------------------------------------------------------------------------

-- enable or disable the usage of the movement between zones
ENABLE_VEAF_RANDOM_MOVE_ZONE = true
-- part of the group name identifying the zone where groups can move
VEAF_random_move_zone_zoneTag = 'veafrz'
-- part of the group name identifying the groups affected
VEAF_random_move_zone_groupTag = 'veafrz'
-- time in seconds before the groups will have a new waypoint
VEAF_random_move_zone_timer = 600

------------------------------------------------------------------------------------------------------------
-- Configuration for the auto dismount for ground units
------------------------------------------------------------------------------------------------------------

-- enable troops to embark and disembark form ground vehicle
ENABLE_VEAF_DISMOUNT_GROUND = true
-- tag in the vehicle name that will have dismount with a random dismount
VEAF_dismount_ground_random_tag = 'veafdm_rnd'
-- tag in the vehicle name that will have dismount with a fire-team (rifles)
VEAF_dismount_ground_soldiers_tag = 'veafdm_sol'
-- tag in the vehicle name that will have dismount with a AAA
VEAF_dismount_ground_AAA_tag = 'veafdm_aaa'
-- tag in the vehicle name that will have dismount with a manpads
VEAF_dismount_ground_manpads_tag = 'veafdm_mpd'
-- tag in the vehicle name that will have dismount with a mortar team
VEAF_dismount_ground_mortars_tag = 'veafdm_mot'

-- in case of random : probability of dismounting a type of unit in percent, default is soldier squad
VEAF_dismount_ground_mortar_prob = 25
VEAF_dismount_ground_AAA_prob = 10
VEAF_dismount_ground_manpads_prob = 05

------------------------------------------------------------------------------------------------------------
-- Configuration for automatic objectives/sites generation in zone
------------------------------------------------------------------------------------------------------------
-- enable the creation of objectives in named zones
ENABLE_VEAF_CREATE_OBJECTIVES = true

-- tag in the zone name to get a random objective
VEAF_obj_zone_random_zoneTag = "veafobj_rnd"
-- tag in the zone name to get a warehouse site
VEAF_obj_zone_warhouse_zoneTag = "veafobj_wh"
-- tag in the zone name to get a factory site
VEAF_obj_zone_factory_zoneTag = "veafobj_fac"
-- tag in the zone name to get a oil pump station site
VEAF_obj_zone_oilPumpingSite_zoneTag = "veafobj_pump"
-- tag in the zone name to get a logistics site
VEAF_obj_zone_logisticCenter_zoneTag = "veafobj_log"


------------------------------------------------------------------------------------------------------------
-- Configuration for automatic ground group patrol
------------------------------------------------------------------------------------------------------------
VEAF_ground_patrol_groupTag = "veafpat"



------------------------------------------------------------------------------------------------------------
-- Configuration for automatic generation of smokes in zones (random colours) 
------------------------------------------------------------------------------------------------------------
-- enable the smoke generation in tagged zones. 
ENABLE_VEAF_GENERATE_RANDOM_SMOKES = true

-- tag in the zone name where to generate smokes
VEAF_generate_random_smokes_in_zone_zoneTag = "VEAFsmokernd"
-- delay since last generation before smokes new smokes are generated in seconds
VEAF_generate_random_smokes_in_zone_timer = 300
-- number of smokes generated each time. 
VEAF_generate_random_smokes_in_zone_smokesNumber = 10



------------------------------------------------------------------------
----- NO MODIFICATION BELOW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
----- NO MODIFICATION BELOW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
----- NO MODIFICATION BELOW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
----- NO MODIFICATION BELOW THIS POINT UNLESS YOU KNOW WHAT YOU DO -----
------------------------------------------------------------------------

------------------------------------------------------------------------------
-- function : VEAF_get_units_with_tag
-- args     : 1, searchTag : part of the unit name to search in the zone list
-- output   : array : units identified
------------------------------------------------------------------------------
-- Objective: returns an array of units identified by the tag in arg1
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 18/11/14 + creation
------------------------------------------------------------------------------
function VEAF_get_units_with_tag(searchTag)

	local unitsArray = {}
	
	for _, u in pairs(mist.DBs.aliveUnits) do
		name = u.unit:getName()
		if string.find(string.lower(name), string.lower(searchTag)) then
            table.insert(unitsArray, name)
        end
	end
	
	return unitsArray
	
end

------------------------------------------------------------------------------
-- function : VEAF_get_zones_with_tag
-- args     : 1, searchTag : part of the zone name to search in the zone list
-- output   : array : groups identified
------------------------------------------------------------------------------
-- Objective: returns an array of groups identified by the tag in arg1
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 16/11/14 + creation
------------------------------------------------------------------------------
function VEAF_get_zones_with_tag(searchTag)

    local zonesArray = {}

    for name, zone in pairs(mist.DBs.zonesByName) do
        if string.find(string.lower(name), string.lower(searchTag)) then
            table.insert(zonesArray, name)
        end
    end
    return zonesArray;
    
end

------------------------------------------------------------------------------
-- function : VEAF_get_groups_with_tag
-- args     : 1, searchTag : part of the name to search in the group list
-- output   : array : groups identified
------------------------------------------------------------------------------
-- Objective: returns an array of groups identified by the tag in arg1
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 12/11/14 + creation
-- Version  : 1.1 16/11/14 ~ case sensitive removed
------------------------------------------------------------------------------
function VEAF_get_groups_with_tag(searchTag)

	local groupsArray = {}
	
	 for groupName, groupData in pairs(mist.DBs.groupsByName) do
		if string.find(string.lower(groupName), string.lower(searchTag)) then
			table.insert(groupsArray, groupName)
		end
	end
	return groupsArray
	
end

------------------------------------------------------------------------------
-- function : VEAF_get_group_coalition
-- args     : 1, groupName : exact name of the group to seachr the coa for
-- output   : array : groups identified
------------------------------------------------------------------------------
-- Objective: returns the coalition blue or red of the group
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 17/11/14 + creation
------------------------------------------------------------------------------
function VEAF_get_group_coalition(groupName)
	
	local groupCoa = 'unknown'
	
	for groupName, groupData in pairs(mist.DBs.groupsByName) do
		if (string.lower(groupName) == string.lower(searchTag)) then
			groupCoa = groupData.coalition
		end
	end
	return groupCoa
	
end

function VEAF_get_terrain_altitude(x, z)

    local zoneAlt = 42
    
    local vec2 = {}
    vec2.x = x
    vec2.y = z
    

    altitude = land.getHeight(vec2)
    
    return altitude;
    
end


-- Private function that will return the mount type 
function _VEAF_get_random_mount_type(proba)
	
	-- random values 
	--local proba = 0
	local maxprobaName = ''
	local maxprobaValue = 0
	local middleProbaName = ''
	local middleProbaValue = 0
	local lowProbaName = ''
	local lowProbaValue = 0
	
	local mountType = "Rifle"
	


	tableProba = {
					{VEAF_dismount_ground_mortar_prob, 'VEAF_dismount_ground_mortar_prob'},
					{VEAF_dismount_ground_AAA_prob, 'VEAF_dismount_ground_AAA_prob'},
					{VEAF_dismount_ground_manpads_prob,'VEAF_dismount_ground_manpads_prob'}
				 }
	
    table.sort(tableProba, compare)
	
	-- dereferenced vars : 
    maxprobaName = tableProba[3][2]
	maxprobaValue = tableProba[3][1]
	middleProbaName = tableProba[2][2]
	middleProbaValue = tableProba[2][1]
    lowProbaName = tableProba[1][2]
	lowProbaValue = tableProba[1][1]
	
	-- check which probability is matched
	if(proba <= lowProbaValue) then
		doProba = "low"
	elseif ( (proba > lowProbaValue) and (proba <= middleProbaValue) ) then
		doProba = "middle"
	elseif ( (proba > middleProbaValue) and (proba <= maxprobaValue) ) then
		doProba = "high"
	else
		doProba = "default"
	end
	
	-- check if we are in low probability
	if ( doProba == "low" ) then
	
		for _,p in pairs(tableProba) do
			if (lowProbaName == 'VEAF_dismount_ground_mortar_prob') then
				mountType = "Mortar"
			elseif (lowProbaName == 'VEAF_dismount_ground_AAA_prob') then
				mountType = "ZU-23"
			elseif (lowProbaName == 'VEAF_dismount_ground_manpads_prob') then	
				mountType = "MANPADS"
			end
		end
	
	end
	
	-- check if we are in middle probability
	if ( doProba == "middle" ) then
	
		for _,p in pairs(tableProba) do
			if (middleProbaName == 'VEAF_dismount_ground_mortar_prob') then
				mountType = "Mortar"
			elseif (middleProbaName == 'VEAF_dismount_ground_AAA_prob') then
				mountType = "ZU-23"
			elseif (middleProbaName == 'VEAF_dismount_ground_manpads_prob') then	
				mountType = "MANPADS"
			end
		end
	
	end	
	
	-- check if we are in high probability
	if ( doProba == "high" ) then
	
		for _,p in pairs(tableProba) do
			if (maxprobaName == 'VEAF_dismount_ground_mortar_prob') then
				mountType = "Mortar"
			elseif (maxprobaName == 'VEAF_dismount_ground_AAA_prob') then
				mountType = "ZU-23"
			elseif (maxprobaName == 'VEAF_dismount_ground_manpads_prob') then	
				mountType = "MANPADS"
			end
		end
	
	end	

	-- else the mountType is set to default 'rifle'
	
			
	return mountType

end

-- core function used for array compare in table sort : table.sort(myArray, compare)
function compare(a,b)
     return a[1] < b[1]
end


------------------------------------------------------------------------------
-- function : VEAF_get_zone_radius
-- args     : zoneName, string : name of a zone
-- output   : radius, integer (default 42)
------------------------------------------------------------------------------
-- Objective: retreive the radius of a zone by its name
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 18/11/14 + creation
------------------------------------------------------------------------------
function VEAF_get_zone_radius(zoneName)

    local zoneRadius = 42

    for name, zone in pairs(mist.DBs.zonesByName) do
        if (string.lower(name) == string.lower(zoneName)) then
            zoneRadius = zone.radius
        end
    end
    return zoneRadius;
    
end

------------------------------------------------------------------------------
-- function : VEAF_get_zone_radius
-- args     : zoneName, string : name of a zone
-- output   : radius, integer (default 42)
------------------------------------------------------------------------------
-- Objective: retreive the radius of a zone by its name
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 18/11/14 + creation
------------------------------------------------------------------------------
function VEAF_get_zone_altitude(zoneName)

    local zoneAlt = 42

    for name, zone in pairs(mist.DBs.zonesByName) do
        if (string.lower(name) == string.lower(zoneName)) then
            zoneAlt = zone.y
        end
    end
    return zoneAlt;
    
end


------------------------------------------------------------------------------
-- function : VEAF_generate_objective_warehouse
-- args     : country, string : country of the warhouse (ex : USA, Russia)
--   		: zoneName, string : the name of the zone to pop the objective in. 
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: create a warehouse site with a little randomization in a zone.
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 18/11/14 + creation
------------------------------------------------------------------------------
function VEAF_generate_objective_warehouseSite(side, zoneName)
	
    local maxRadius = VEAF_get_zone_radius(zoneName)
	local zone = trigger.misc.getZone(zoneName)        
	local obj = {}
	local country = "Russia"
    
    if (string.lower(side) == "blue") then 
        country = "USA"
    end
    
	obj.name = "Depot_" .. math.random(0, 1000)
	obj.x = zone.point.x + math.random(-maxRadius, maxRadius)
	obj.y = zone.point.z + math.random(-maxRadius, maxRadius) -- z is Y lol wtf ED wtf lol ... ahah ... it costed me 3 hours >_<!!
	obj.country = country

    -- warehouse at the center of the coordinates.
    local warehouse = 
    {
        type = "Warehouse",
        country = obj.country, 
        category = "Warhouses", 
        x = obj.x,
        y = obj.y,
        name = obj.name .."_warhouse_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }

    local fueltank1 = 
    {
        type = "Tank",
        country = obj.country, 
        category = "Warhouses", 
        x = obj.x + math.random(30, 70),
        y = obj.y + math.random(-100, 100),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading =  math.random() * 10,
        dead = false
    }

    local fueltank2 = 
    {
        type = "Tank 2",
        country = obj.country, 
        category = "Warhouses", 
        x = obj.x + math.random(-60, -40 ),
        y = obj.y + math.random(-100, 100),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }

    local fueltank3 = 
    {
        type = "Tank 3",
        country = obj.country, 
        category = "Warhouses", 
        x = obj.x + math.random(60, 120 ),
        y = obj.y + math.random(-50, 50),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
	
	-- adding up to 4 silos to randomize a little
	siloNumber = math.random(0,4)
	
	for i=0,siloNumber do
	
	    local dmpi = 
		{
			type = "Tank",
			country = obj.country, 
			category = "Warhouses", 
			x = obj.x + math.random(-100, -10),
			y = obj.y + math.random(-100, 100),
			name = obj.name .. "_tank_" .. math.random(0, 100) , 
			heading =  math.random() * 10,
			dead = false
		}
		 mist.dynAddStatic(dmpi)
	end
	
	
    mist.dynAddStatic(warehouse)
    mist.dynAddStatic(fueltank1)
    mist.dynAddStatic(fueltank2)
    mist.dynAddStatic(fueltank3)
    
end

function VEAF_generate_objective_factorySite(side, zoneName)
	
    local maxRadius = VEAF_get_zone_radius(zoneName)
	local zone = trigger.misc.getZone(zoneName)        
	local obj = {}
	local country = "Russia"
    
    if (string.lower(side) == "blue") then 
        country = "USA"
    end
    
	obj.name = "LogisticsRepair_" .. math.random(0, 1000)
	obj.x = zone.point.x + math.random(-maxRadius, maxRadius)
	obj.y = zone.point.z + math.random(-maxRadius, maxRadius) -- z is Y lol wtf ED wtf lol ... ahah ... it costed me 3 hours >_<!!
	obj.country = country

    -- warehouse at the center of the coordinates.
   local dmpi1 = 
    {
        type = "Workshop A",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x,
        y = obj.y,
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }

    local dmpi2 = 
    {
        type = "Repair workshop",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(100, 150),
        y = obj.y + math.random(-100, 150),
        name = obj.name .. "_depot_" .. math.random(0, 100) , 
        heading =  math.random() * 10,
        dead = false
    }

    local dmpi3 = 
    {
        type = "Electric power box",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(-60, -20 ),
        y = obj.y + math.random(-100, 100),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
	
	local dmpi4 = 
    {
        type = "WC",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(-30, -20 ),
        y = obj.y + math.random(10, 80),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
    
    local dmpi5 = 
    {
        type = "Electric power box",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(20, 60 ),
        y = obj.y + math.random(-100, 100),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
	

    mist.dynAddStatic(dmpi1)
    mist.dynAddStatic(dmpi2)
    mist.dynAddStatic(dmpi3)
	mist.dynAddStatic(dmpi4)
	mist.dynAddStatic(dmpi5)

end

function VEAF_generate_objective_oilPumpingSite(side, zoneName)
	
    local maxRadius = VEAF_get_zone_radius(zoneName)
	local zone = trigger.misc.getZone(zoneName)        
	local obj = {}
	local country = "Russia"
    
    if (string.lower(side) == "blue") then 
        country = "USA"
    end
    
	obj.name = "FuelPlant_" .. math.random(0, 1000)
	obj.x = zone.point.x + math.random(-maxRadius, maxRadius)
	obj.y = zone.point.z + math.random(-maxRadius, maxRadius) -- z is Y lol wtf ED wtf lol ... ahah ... it costed me 3 hours >_<!!
	obj.country = country

    -- warehouse at the center of the coordinates.
   local dmpi1 = 
    {
        type = "Chemical tank A",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x,
        y = obj.y,
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }

    local dmpi2 = 
    {
        type = "Oil derrick",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(100, 150),
        y = obj.y + math.random(-100, 150),
        name = obj.name .. "_depot_" .. math.random(0, 100) , 
        heading =  math.random() * 10,
        dead = false
    }

    local dmpi3 = 
    {
        type = "Oil derrick",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(-60, -20 ),
        y = obj.y + math.random(-100, 100),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
	
	local dmpi4 = 
    {
        type = "Oil derrick",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(-30, -20 ),
        y = obj.y + math.random(10, 80),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
    
    local dmpi5 = 
    {
        type = "Oil derrick",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(20, 60 ),
        y = obj.y + math.random(-100, 100),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
    
    local dmpi6 = 
    {
        type = "Chemical tank A",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(10, 20 ),
        y = obj.y + math.random(-100, 100),
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
    
    local dmpi7 = 
    {
        type = "Pump station",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(40, 150 ),
        y = obj.y + math.random(-100, 100),
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
    
    local dmpi8 = 
    {
        type = "Pump station",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(40, 150 ),
        y = obj.y + math.random(-100, 100),
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
	

    mist.dynAddStatic(dmpi1)
    mist.dynAddStatic(dmpi2)
    mist.dynAddStatic(dmpi3)
	mist.dynAddStatic(dmpi4)
	mist.dynAddStatic(dmpi5)
    mist.dynAddStatic(dmpi6)
    mist.dynAddStatic(dmpi7)
    mist.dynAddStatic(dmpi8)

end

function VEAF_generate_objective_logisticCenterSite(side, zoneName)
	
    local maxRadius = VEAF_get_zone_radius(zoneName)
	local zone = trigger.misc.getZone(zoneName)        
	local obj = {}
	local country = "Russia"
    
    if (string.lower(side) == "blue") then 
        country = "USA"
    end
    
	obj.name = "FuelPlant_" .. math.random(0, 1000)
	obj.x = zone.point.x + math.random(-maxRadius, maxRadius)
	obj.y = zone.point.z + math.random(-maxRadius, maxRadius) -- z is Y lol wtf ED wtf lol ... ahah ... it costed me 3 hours >_<!!
	obj.country = country
    
    orientation = math.random() * 10

    -- warehouse at the center of the coordinates.
   local dmpi1 = 
    {
        type = "Tech hangar A",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x,
        y = obj.y,
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = orientation,
        dead = false
    }

    local dmpi2 = 
    {
        type = "Bunker",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(200, 300),
        y = obj.y + math.random(-300, -200),
        name = obj.name .. "_depot_" .. math.random(0, 100) , 
        heading =  math.random() * 10,
        dead = false
    }

    local dmpi3 = 
    {
        type = "Bunker",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(-300, -200),
        y = obj.y + math.random(200, 300),
        name = obj.name .. "_depot_" .. math.random(0, 100) , 
        heading =  math.random() * 10,
        dead = false
    }

	local dmpi4 = 
    {
        type = "Tech hangar A",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(-30, -20 ),
        y = obj.y + math.random(10, 80),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = orientation,
        dead = false
    }
    
    local dmpi5 = 
    {
        type = "Watchtower",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(10, 50 ),
        y = obj.y + math.random(200, 300),
        name = obj.name .. "_tank_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
    
    local dmpi6 = 
    {
        type = "outpost",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(40, 60 ),
        y = obj.y + math.random(-100, 100),
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
    
    local dmpi7 = 
    {
        type = "Subsidiary structure 2",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(50, 100 ),
        y = obj.y + math.random(-50, 50),
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
    
    local dmpi8 = 
    {
        type = "Watchtower",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(-300, -200 ),
        y = obj.y + math.random(200, 300),
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
    
    
    local dmpi9 = 
    {
        type = "Watchtower",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(100, 200 ),
        y = obj.y + math.random(-300, -200),
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = math.random() * 10,
        dead = false
    }
	
	local dmpi10 = 
    {
        type = "Fuel tank",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(-100, -50 ),
        y = obj.y + math.random(-50, 50),
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = orientation,
        dead = false
    }
   	local dmpi11 = 
    {
        type = "Fuel tank",
        country = obj.country, 
        category = "Fortifications", 
        x = obj.x + math.random(-100, -50 ),
        y = obj.y + math.random(-50, 50),
        name = obj.name .."_factory_" .. math.random(0, 100) , 
        heading = orientation,
        dead = false
    }

    mist.dynAddStatic(dmpi1)
    mist.dynAddStatic(dmpi2)
    mist.dynAddStatic(dmpi3)
	mist.dynAddStatic(dmpi4)
	mist.dynAddStatic(dmpi5)
    mist.dynAddStatic(dmpi6)
    mist.dynAddStatic(dmpi7)
    mist.dynAddStatic(dmpi8)
    mist.dynAddStatic(dmpi9)
    mist.dynAddStatic(dmpi10)
    mist.dynAddStatic(dmpi11)

end


function AUTO_VEAF_create_objectives()
	
	-- init arrays
	local objZonesRandom = VEAF_get_zones_with_tag(VEAF_obj_zone_random_zoneTag)
	local objZonesWarhouse = VEAF_get_zones_with_tag(VEAF_obj_zone_warhouse_zoneTag)
	local objZonesFactory = VEAF_get_zones_with_tag(VEAF_obj_zone_factory_zoneTag)
	local objZonesOilPumpingSite = VEAF_get_zones_with_tag(VEAF_obj_zone_oilPumpingSite_zoneTag)
	local objZonesLogisticCenter = VEAF_get_zones_with_tag(VEAF_obj_zone_logisticCenter_zoneTag)
	local coalition = "red"
	

    
	-- pop zones warhouse
	for _, zoneName in pairs(objZonesWarhouse) do
		coaliation = "red"
		if(string.find(string.lower(zoneName), "blueside")) then
			coaliation = "blue"
		end
		VEAF_generate_objective_warehouseSite(coaliation, zoneName)
	end
	
	-- pop zones factory
	for _, zoneName in pairs(objZonesFactory) do
		coaliation = "red"
		if(string.find(string.lower(zoneName), "blueside")) then
			coaliation = "blue"
		end
		VEAF_generate_objective_factorySite(coaliation, zoneName)
	end
	
	-- pop zones oil pumping 
	for _, zoneName in pairs(objZonesOilPumpingSite) do
		coaliation = "red"
		if(string.find(string.lower(zoneName), "blueside")) then
			coaliation = "blue"
		end
		VEAF_generate_objective_oilPumpingSite(coaliation, zoneName)
	end
	
	-- pop zones logistics 
	for _, zoneName in pairs(objZonesLogisticCenter) do
		coaliation = "red"
		if(string.find(string.lower(zoneName), "blueside")) then
			coaliation = "blue"
		end
		VEAF_generate_objective_logisticCenterSite(coaliation, zoneName)
	end
	
	-- pop zones random 
	for _, zoneName in pairs(objZonesRandom) do
		coaliation = "red"
		if(string.find(string.lower(zoneName), "blueside")) then
			coaliation = "blue"
		end
		
		-- randomize !
		objType = math.random(1,4)
		
		if (objType == 1) then 
			VEAF_generate_objective_warehouseSite(coaliation, zoneName)
		elseif (objType == 2) then 
			VEAF_generate_objective_factorySite(coaliation, zoneName)
		elseif (objType == 3) then 
			VEAF_generate_objective_oilPumpingSite(coaliation, zoneName)
		elseif (objType == 4) then 
			VEAF_generate_objective_logisticCenterSite(coaliation, zoneName)
		else
			-- lol ? how is it possible >_< ... but it gets there sometimes ... T_T!
			VEAF_generate_objective_warehouseSite(coaliation, zoneName)
		end
	end
	
end



------------------------------------------------------------------------------
-- function : VEAF_random_smoke_in_zone_random
-- args     : 1, string : Name of the zone
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: creates a smoke of a random color inside a zone
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 23/11/14 + creation
-- 			  1.1 05/01/15 ~add randomness to the height of the smoke 	
------------------------------------------------------------------------------
function VEAF_random_smoke_in_zone_random(zoneName)

    local radius = VEAF_get_zone_radius(zoneName)
    local zone = trigger.misc.getZone(zoneName)
    
    local xOffset = math.random(-radius,radius)
    local zOffset = math.random(-radius,radius)
    local yOffset = math.random(-10,0)
    
    local mySmoke = {}
    
    mySmoke.x = zone.point.x + xOffset
    mySmoke.z = zone.point.z + zOffset
    mySmoke.y = VEAF_get_terrain_altitude(mySmoke.x, mySmoke.z) + yOffset  -- offseting smoke to make them look a little different every time
    

    colorId = math.random(1,5)
    
    if(colorId == 1) then colorValue = trigger.smokeColor.Green
        elseif (colorId == 2) then colorValue = trigger.smokeColor.Red
        elseif (colorId == 3) then colorValue = trigger.smokeColor.White
        elseif (colorId == 4) then colorValue = trigger.smokeColor.Orange
        elseif (colorId == 5) then colorValue = trigger.smokeColor.Blue
    end

    trigger.action.smoke(mySmoke,colorValue)
    
    return {mySmoke}
end


------------------------------------------------------------------------------
-- function : AUTO_VEAF_ground_patrol_group
-- args     : N/A
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: core function to enable smoke generation. 
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 01/01/15 + creation
------------------------------------------------------------------------------
function AUTO_VEAF_generate_random_smokes_in_zone()
    
	--- search zones with tag (global var)
	local zoneList = VEAF_get_zones_with_tag(VEAF_generate_random_smokes_in_zone_zoneTag)
	local smokeNumberEachTime = VEAF_generate_random_smokes_in_zone_smokesNumber
	
	-- actions !
	for id, zoneName in pairs(zoneList) do
			for number = 0, smokeNumberEachTime, 1 do
				VEAF_random_smoke_in_zone_random(zoneName)
			end
	end

    -- schedule function
    timer.scheduleFunction(AUTO_VEAF_generate_random_smokes_in_zone, nil, timer.getTime() + VEAF_generate_random_smokes_in_zone_timer)
end


------------------------------------------------------------------------------
-- function : AUTO_VEAF_move_group_to_random_zone
-- args     : N/A
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: move any groups identified with a tag to a random zone list identified by a tag
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 0.1 10/11/14 + creation
--            0.2 12/11/14 + add automation
--            1.0 16/11/14 ~ replace zone list for tag search, 
--						   + add tag search param for group search
------------------------------------------------------------------------------
function AUTO_VEAF_move_group_to_random_zone()

	--- search zones with tag (global var)
	local zoneList  = VEAF_get_zones_with_tag(VEAF_random_move_zone_zoneTag)
	local groupList = VEAF_get_groups_with_tag(VEAF_random_move_zone_groupTag)
	
	-- actions !
	for id, groupName in pairs(groupList) do
			VEAF_move_group_to_random_zone(groupName, zoneList)
	end

    -- schedule function
    timer.scheduleFunction(AUTO_VEAF_move_group_to_random_zone, nil, timer.getTime() + VEAF_random_move_zone_timer)
end

-- core function to move units
function VEAF_move_group_to_random_zone(group, zoneList)
	mist.groupToRandomZone(group, zoneList)
end


------------------------------------------------------------------------------
-- function : AUTO_VEAF_ground_patrol_group
-- args     : N/A
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: ground groups identified by a tag will patrol to first waypoint when they arrive to last waypoint
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 0.1 01/12/14 + creation
------------------------------------------------------------------------------
function AUTO_VEAF_ground_patrol_group()

	--- search zones with tag (global var)
	local groupList = VEAF_get_groups_with_tag(VEAF_ground_patrol_groupTag)
	
	-- actions !
	for id, groupName in pairs(groupList) do
			mist.ground.patrol(groupName)
	end

    -- schedule function
    --timer.scheduleFunction(AUTO_VEAF_move_group_to_random_zone, nil, timer.getTime() + VEAF_random_move_zone_timer)
end


------------------------------------------------------------------------------
-- function : AUTO_VEAF_move_group_to_random_zone
-- args     : N/A
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: add dismount to units based on a tag in their name
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 17/11/14 + creation
------------------------------------------------------------------------------
function AUTO_VEAF_dismount_ground()

	--- search units with tag (global var)
	local unitsListWithRandom = VEAF_get_units_with_tag(VEAF_dismount_ground_random_tag)
	local unitsListOnlySoldier = VEAF_get_units_with_tag(VEAF_dismount_ground_soldiers_tag)
	local unitsListOnlyAAA = VEAF_get_units_with_tag(VEAF_dismount_ground_AAA_tag)
	local unitsListOnlyManpads = VEAF_get_units_with_tag(VEAF_dismount_ground_manpads_tag)
	local unitsListOnlyMortars = VEAF_get_units_with_tag(VEAF_dismount_ground_mortars_tag)
	
	
	-- add dismount with rifles/soldiers only
	for id, unitName in pairs(unitsListOnlySoldier) do
			AddDismounts(unitName, "Rifle")
	end
	
	-- add dismount with AAA only
	for id, unitName in pairs(unitsListOnlyAAA) do
			AddDismounts(unitName, "ZU-23")
	end
	
	-- add dismount with manpads only
	for id, unitName in pairs(unitsListOnlyManpads) do
			AddDismounts(unitName, "MANPADS")
	end
	
	-- add dismount with manpads only
	for id, unitName in pairs(unitsListOnlyMortars) do
			AddDismounts(unitName, "Mortar")
	end
	
	-- add dismount with manpads only
	for id, unitName in pairs(unitsListWithRandom) do
			-- making a little random magic pipidibou !
			proba = math.random(1,100)
			mountType = _VEAF_get_random_mount_type(proba)
			AddDismounts(unitName, mountType)
	end

    -- schedule function
    --timer.scheduleFunction(AUTO_VEAF_move_group_to_random_zone, nil, timer.getTime() + VEAF_random_move_zone_timer)
end

------------------------------------------------------------------------------
-- function : VEAF_controller
-- args     : N/A
-- output   : N/A
------------------------------------------------------------------------------
-- Objective: controls if functions have to be executed or not based on global vas.
-- Author   : VEAF MagicBra
------------------------------------------------------------------------------
-- Version  : 1.0 16/11/14 + creation
------------------------------------------------------------------------------
function VEAF_controller() 
	
	if (ENABLE_VEAF_RANDOM_MOVE_ZONE) then
		AUTO_VEAF_move_group_to_random_zone()
	end
	if (ENABLE_VEAF_DISMOUNT_GROUND) then
		AUTO_VEAF_dismount_ground()
	end
	if (ENABLE_VEAF_CREATE_OBJECTIVES) then
		AUTO_VEAF_create_objectives()
	end
	if (ENABLE_VEAF_GENERATE_RANDOM_SMOKES) then
		AUTO_VEAF_generate_random_smokes_in_zone()
	end	
	
	AUTO_VEAF_ground_patrol_group()
	
end

-- main loop
timer.scheduleFunction(VEAF_controller, nil, timer.getTime() + 1)
--AUTO_VEAF_dismount_ground()