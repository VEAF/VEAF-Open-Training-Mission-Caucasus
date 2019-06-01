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
    {name="CSG-01 Tarawa", description="Tarawa (LHA)", information="Tacan 1X\nDatalink 310 Mhz\nVHF 304 Mhz"},  
    {name="CSG-74 Stennis", description="Stennis (CVN)", information="Tacan 74X\nDatalink 321 Mhz\nICLS 1\nVHF 305 Mhz"},  
    {name="T1-Arco", description="Arco (KC-135 MPRS)", information="Tacan 6Y\nVHF 138.2 Mhz"}, 
    {name="T2-Shell", description="Shell (KC-135 MPRS)", information="Tacan 14Y\nVHF 134.7 Mhz"},  
    {name="T3-Texaco", description="Texaco-1 (KC-135 MPRS)", information="Tacan 12Y\nVHF 132.5 Mhz"},  
    {name="CVN-74 Stennis S3B-Tanker", description="Texaco-7 (S3-B)", information="Tacan 75Y\nVHF 133.750 Mhz"},  
    {name="D1-Reaper", description="Colt-1 FAC (MQ-9)", information="VHF 253 Mhz", jtac=1688},  
    {name="D2-Reaper", description="Dodge-1 FAC (MQ-9)", information="VHF 254 Mhz", jtac=1687},  
    {name="A1-Overlord", description="Overlord (E-2D)", information="Datalink 315.3 Mhz\nUHF 251 Mhz"},  
    {name="A2-Overlordsky", description="(RED) Overlordsky (A-50)", information="UHF 266 Mhz"},  
    {name="Meet Mig-21", description="RED Mig-21 (dogfight zone)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\""},
    {name="Meet Mig-29", description="RED Mig-29 (dogfight zone)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\"" },
    {name="Meet Mig-29*2", description="RED Mig-29x2 (dogfight zone)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\""},
    {name="Meet Mig-29*4", description="RED Mig-29x4 (dogfight zone)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\""},
    {name="Meet F-5E-3 *2", description="RED F-5E-3x2 (dogfight zone)", disposable=true, information="They spawn near N41° 09' 31\" E043° 05' 08\""},
}
