-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF ASSETS configuration script
-- By zip (2019)
--
-- Features:
-- ---------
-- Contains all the Caucasus mission-specific configuration for the ASSETS module
-- 
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires veafAssets.lua
-- 
-- Load the script:
-- ----------------
-- load it in a trigger after loading veafAssets
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafAssets.Assets = {
    -- list the assets common to all missions below
    {sort=1, name="CSG-01 Tarawa", description="Tarawa (LHA)", information="Tacan 1X\nDatalink 310 Mhz\n304 Mhz"},  
    {sort=2, name="CSG-74 Stennis", description="Stennis (CVN)", information="Tacan 74X\nDatalink 321 Mhz\nICLS 1\n305 Mhz"},  
    {sort=3, name="T1-Arco", description="Arco (KC-135)", information="Tacan 11Y\n290.70 Mhz\nZone OUEST", linked="T1-Arco escort"}, 
    {sort=5, name="T3-Texaco", description="Texaco (KC-135 MPRS)", information="Tacan 13Y\n290.30 Mhz\nZone OUEST", linked="T3-Texaco escort"},  
    {sort=4, name="T2-Shell", description="Shell (KC-135 MPRS)", information="Tacan 12Y\n290.10 Mhz\nZone EST", linked="T2-Shell escort"},  
    {sort=6, name="T4-Shell-B", description="Shell-B (KC-135)", information="Tacan 14Y\n290.50 Mhz\nZone EST", linked="T4-Shell-B escort"},  
    {sort=6, name="T5-Petrolsky", description="900 (IL-78M, RED)", information="267 Mhz", linked="T5-Petrolsky escort"},  
    {sort=7, name="CVN-74 Stennis S3B-Tanker", description="Texaco-7 (S3-B)", information="Tacan 75Y\n290.90 Mhz\nZone PA"},  
    {sort=8, name="D1-Reaper", description="Colt-1 FAC (MQ-9)", information="118.80 Mhz", jtac=1688},  
    {sort=9, name="D2-Reaper", description="Dodge-1 FAC (MQ-9)", information="118.90 Mhz", jtac=1687},  
    {sort=10, name="A1-Magic", description="Magic (E-2D)", information="Datalink 315.3 Mhz\n282.20 Mhz", linked="A1-Magic escort"},  
    {sort=11, name="A2-Overlordsky", description="Overlordsky (A-50, RED)", information="112.12 Mhz"},  
}

veafAssets.logInfo("Loading configuration")

veafAssets.logInfo("Setting move tanker radio menus")
table.insert(veafMove.Tankers, "T1-Arco")
table.insert(veafMove.Tankers, "T2-Shell")
table.insert(veafMove.Tankers, "T3-Texaco")
table.insert(veafMove.Tankers, "T4-Shell-B")
table.insert(veafMove.Tankers, "T5-Petrolsky")
