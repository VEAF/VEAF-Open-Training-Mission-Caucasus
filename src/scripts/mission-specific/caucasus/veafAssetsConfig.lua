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
    {sort=1, name="CSG-01 Tarawa", description="Tarawa (LHA)", information="Tacan 1X\nDatalink 310 Mhz\nVHF 304 Mhz"},  
    {sort=2, name="CSG-74 Stennis", description="Stennis (CVN)", information="Tacan 74X\nDatalink 321 Mhz\nICLS 1\nVHF 305 Mhz"},  
    {sort=3, name="T1-Arco", description="Arco (KC-135)", information="Tacan 11Y\nVHF 130.4 Mhz\nZone OUEST"}, 
    {sort=5, name="T3-Texaco", description="Texaco (KC-135 MPRS)", information="Tacan 13Y\nVHF 130.2 Mhz\nZone OUEST"},  
    {sort=4, name="T2-Shell", description="Shell (KC-135 MPRS)", information="Tacan 12Y\nVHF 130.3 Mhz\nZone EST"},  
    {sort=6, name="T4-Shell-B", description="Shell-B (KC-135)", information="Tacan 14Y\nVHF 130.1 Mhz\nZone EST"},  
    {sort=7, name="CVN-74 Stennis S3B-Tanker", description="Texaco-7 (S3-B)", information="Tacan 75Y\nVHF 133.750 Mhz\nZone PA"},  
    {sort=8, name="D1-Reaper", description="Colt-1 FAC (MQ-9)", information="VHF 253 Mhz", jtac=1688},  
    {sort=9, name="D2-Reaper", description="Dodge-1 FAC (MQ-9)", information="VHF 254 Mhz", jtac=1687},  
    {sort=10, name="A1-Overlord", description="Overlord (E-2D)", information="Datalink 315.3 Mhz\nUHF 251 Mhz"},  
    {sort=11, name="A2-Overlordsky", description="Overlordsky (A-50, RED)", information="UHF 266 Mhz"},  
    {sort=12, name="Meet Mig-21", description="Mig-21 (dogfight zone, RED)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\""},
    {sort=13, name="Meet Mig-29", description="Mig-29 (dogfight zone, RED)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\"" },
    {sort=14, name="Meet Mig-29*2", description="Mig-29x2 (dogfight zone, RED)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\""},
    {sort=15, name="Meet Mig-29*4", description="Mig-29x4 (dogfight zone, RED)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\""},
    {sort=16, name="Meet F-5E-3 *2", description="F-5E-3x2 (dogfight zone, RED)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\""},
}
