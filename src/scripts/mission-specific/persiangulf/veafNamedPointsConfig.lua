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
    {name="AIRBASE Al Dhafra",point={x=-211168,y=0,z=-173476}},
    -- farps
    {name="FARP Berlin",point={x=-218745,y=0,z=-93998}},
    {name="FARP Kish",point={x=62077,y=0,z=-188061}},
    -- points of interest
    {name="RANGE",point={x=-328289,y=0,z=631228}},
    {name="WAR BlueBase",point={x=62638,y=0,z=-186423}}, 
    {name="WAR RedBase",point={x=56709,y=0,z=-157838}},
    {name="WAR Objective1",point={x=59435,y=0,z=-172369}},
}
