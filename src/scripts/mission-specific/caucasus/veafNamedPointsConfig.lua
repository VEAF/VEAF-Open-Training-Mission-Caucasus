-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF NAMEDPOINTS configuration script
-- By zip (2019)
--
-- Features:
-- ---------
-- Contains all the Caucasus mission-specific configuration for the NAMEDPOINTS module
-- 
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires veafNamedPoints.lua
-- 
-- Load the script:
-- ----------------
-- load it in a trigger after loading veafNamedPoints
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafNamedPoints.Points = {
    -- airbases
    {name="AIRBASE Tbilisi",point={x=-315414,y=480,z=897262}},
    {name="AIRBASE Sukhumi",point={x=-219998,y=0,z=563926}},
    {name="AIRBASE Batumi",point={x=-355808,y=0,z=617385}},
    -- farps
    {name="FARP Java",point={x=-247450,y=0,z=799583}},
    {name="FARP Lentehi",point={x=-214442,y=0,z=695610}},
    {name="FARP Aibgha",point={x=-146615,y=0,z=486334}},
    {name="FARP Rista",point={x=-151631,y=0,z=518384}},
    {name="FARP Kaspi",point={x=-290955,y=0,z=847525}}, 
    {name="FARP Beslan",point={x=-131270,y=0,z=846128}}, 
    -- points of interest
    {name="RANGE Kobuleti",point={x=-328289,y=0,z=631228}},
    {name="WAR BlueBase",point={x=-131270,y=0,z=846128}}, 
    {name="WAR RedBase",point={x=-104957,y=0,z=846181}},
    {name="WAR Objective1",point={x=-117764,y=0,z=847293}},
}
