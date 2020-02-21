-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF War on Ground configuration script
-- By zip (2019)
--
-- Features:
-- ---------
-- Contains all the Caucasus mission-specific configuration for AutoGFT
-- 
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires autogft-1_12.lua
-- 
-- Load the script:
-- ----------------
-- load it in a trigger after loading autogft
-------------------------------------------------------------------------------------------------------------------------------------------------------------

local veafAutoGFT_setup_blue = nil
local veafAutoGFT_setup_red = nil

function veafAutoGFT_start(maxReinforceTime)
    if not maxReinforceTime then
        maxReinforceTime = 3600 -- one hour
    end

    -- BLUE
    veafAutoGFT_setup_blue = autogft_Setup:new()
    veafAutoGFT_setup_blue
    :useRandomUnits()
    :addBaseZone("BLUE_BASE")
    :addControlZone("OBJECTIVE_1")
    :setSpeed(30)
    :setCountry(country.id.USA)
    :addRandomUnitAlternative(3, "M-1 Abrams", 3)
    :addRandomUnitAlternative(4, "M-2 Bradley", 4)
    :addRandomUnitAlternative(1, "Vulcan", 1)
    :addRandomUnitAlternative(1, "M1097 Avenger", 1)
    :addRandomUnitAlternative(1, "M48 Chaparral", 1)
    :addTaskGroup()
    :addRandomUnitAlternative(3, "M-1 Abrams", 3)
    :addRandomUnitAlternative(4, "M-2 Bradley", 4)
    :addRandomUnitAlternative(1, "Vulcan", 1)
    :addRandomUnitAlternative(1, "M1097 Avenger", 1)
    :addRandomUnitAlternative(1, "M48 Chaparral", 1)
    :addTaskGroup()
    :addRandomUnitAlternative(3, "M-1 Abrams", 3)
    :addRandomUnitAlternative(4, "M-2 Bradley", 4)
    :addRandomUnitAlternative(1, "Vulcan", 1)
    :addRandomUnitAlternative(1, "M1097 Avenger", 1)
    :addRandomUnitAlternative(1, "M48 Chaparral", 1)
    :setReinforceTimerMax(maxReinforceTime)
        
    -- RED
    veafAutoGFT_setup_red = autogft_Setup:new()
    veafAutoGFT_setup_red
    :useRandomUnits()
    :addBaseZone("RED_BASE")
    :addControlZone("OBJECTIVE_1")
    :setSpeed(30)
    :setCountry(country.id.RUSSIA)
    :addRandomUnitAlternative(3, "T-80UD", 3)
    :addRandomUnitAlternative(4, "BMP-2", 4)
    :addRandomUnitAlternative(1, "ZSU-23-4 Shilka", 1)
    :addRandomUnitAlternative(1, "Strela-1 9P31", 1)
    :addTaskGroup()
    :addRandomUnitAlternative(3, "T-80UD", 3)
    :addRandomUnitAlternative(4, "BMP-2", 4)
    :addRandomUnitAlternative(1, "ZSU-23-4 Shilka", 1)
    :addRandomUnitAlternative(1, "Strela-1 9P31", 1)
    :addTaskGroup()
    :addRandomUnitAlternative(3, "T-80UD", 3)
    :addRandomUnitAlternative(4, "BMP-2", 4)
    :addRandomUnitAlternative(1, "ZSU-23-4 Shilka", 1)
    :addRandomUnitAlternative(1, "Strela-1 9P31", 1)
    :setReinforceTimerMax(maxReinforceTime)
end

function veafAutoGFT_setReinforceTome(maxReinforceTime)
    veafAutoGFT_setup_blue:setReinforceTimerMax(maxReinforceTime)
    veafAutoGFT_setup_red:setReinforceTimerMax(maxReinforceTime)
end

function veafAutoGFT_stopReinforcing()
    veafAutoGFT_setReinforceTome(5)
end

