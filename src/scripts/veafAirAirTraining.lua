-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Air-air training script - based on CoubyStark's work on TR_AD
-- By zip (2020)
--
-- Features:
-- ---------
-- Waves of bombers can be spawned by selecting a command in a radio menu
-- 
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires Moose.lua
-- * It also requires veafRadio.lua
-- 
-- Load the script:
-- ----------------
-- load it in a trigger after loading veafRadio
-------------------------------------------------------------------------------------------------------------------------------------------------------------

airAirTraining = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
airAirTraining.Id = "AIR-AIR - "

--- Version.
airAirTraining.Version = "0.0.1"

-- trace level, specific to this module
airAirTraining.Trace = true

airAirTraining.RadioMenuName = "AIR-AIR"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

airAirTraining.rootPath = nil

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function airAirTraining.logInfo(message)
    veaf.logInfo(airAirTraining.Id .. message)
end

function airAirTraining.logDebug(message)
    veaf.logDebug(airAirTraining.Id .. message)
end

function airAirTraining.logTrace(message)
    if message and airAirTraining.Trace then
        veaf.logTrace(airAirTraining.Id .. message)
    end
end

airAirTraining.logInfo("Loading configuration")

-- Function to activate BFM Area Tu-160 Bomber Wave 1 / 8 slow Tu-160
function airAirTraining.BFM_Bomber_Activate_Scenario1(unitName)
    veaf.outTextForUnit(unitName, "Tu-160 Bomber wave scenario 1 - activated\nYou have 10 minutes to destroy bombers", 30)
    local BFM_Wave11 = SPAWN:New("Red Tu-160 Bomber Wave1-1"):Spawn()
    local BFM_Wave12 = SPAWN:New("Red Tu-160 Bomber Wave1-2"):Spawn()
    local BFM_Wave13 = SPAWN:New("Red Tu-160 Bomber Wave1-3"):Spawn()
    local BFM_Wave14 = SPAWN:New("Red Tu-160 Bomber Wave1-4"):Spawn()
    local BFM_Wave15 = SPAWN:New("Red Tu-160 Bomber Wave1-5"):Spawn()
    local BFM_Wave16 = SPAWN:New("Red Tu-160 Bomber Wave1-6"):Spawn()
    local BFM_Wave17 = SPAWN:New("Red Tu-160 Bomber Wave1-7"):Spawn()
    local BFM_Wave18 = SPAWN:New("Red Tu-160 Bomber Wave1-8"):Spawn()
    local BFM_Wave19 = SPAWN:New("Red Tu-160 Bomber Wave1-9"):Spawn()
    SCHEDULER:New( nil,
      function()
        veaf.outTextForUnit(unitName, "Tu-160 Bomber wave scenario 1 - terminated", 30)
        BFM_Wave11:Destroy()
        BFM_Wave12:Destroy()
        BFM_Wave13:Destroy()
        BFM_Wave14:Destroy()
        BFM_Wave15:Destroy()
        BFM_Wave16:Destroy()
        BFM_Wave17:Destroy()
        BFM_Wave18:Destroy()
        BFM_Wave19:Destroy()
      end, {}, 605)
end

-- Function to activate Red attack On Gudauta
function airAirTraining.Red_Attack_On_Gudauta_Activate()
    trigger.action.outText("Red attack detected on Gudauta !\nDestroy the bombers before they hit the base.", 30)
    local BFM_Wave11 = SPAWN:New("Red Attack On Gudauta - Wave 1-1"):Spawn()
    local BFM_Wave12 = SPAWN:New("Red Attack On Gudauta - Wave 1-2"):Spawn()
    local BFM_Wave13 = SPAWN:New("Red Attack On Gudauta - Wave 1-3"):Spawn()
    local BFM_Wave14 = SPAWN:New("Red Attack On Gudauta - Wave 1-4"):Spawn()
    local BFM_Wave21 = SPAWN:New("Red Attack On Gudauta - Wave 2-1"):Spawn()
    local BFM_Wave22 = SPAWN:New("Red Attack On Gudauta - Wave 2-2"):Spawn()
    local BFM_Wave23 = SPAWN:New("Red Attack On Gudauta - Wave 2-3"):Spawn()
        SCHEDULER:New( nil,
      function()
        trigger.action.outText("Red attack On Gudauta - terminated", 30)
        BFM_Wave11:Destroy()
        BFM_Wave12:Destroy()
        BFM_Wave13:Destroy()
        BFM_Wave14:Destroy()
        BFM_Wave21:Destroy()
        BFM_Wave22:Destroy()
        BFM_Wave23:Destroy()
      end, {}, 3600)
end

--- Build the initial radio menu
function airAirTraining.buildRadioMenu()
    airAirTraining.rootPath = veafRadio.addSubMenu(airAirTraining.RadioMenuName)

    veafRadio.addCommandToSubmenu("Training - Bomber Scenario 1 - slow Tu-160", airAirTraining.rootPath, airAirTraining.BFM_Bomber_Activate_Scenario1, nil, veafRadio.USAGE_ForGroup)
    veafRadio.addCommandToSubmenu("Mission - Red attack On Gudauta", airAirTraining.rootPath, airAirTraining.Red_Attack_On_Gudauta_Activate, nil, veafRadio.USAGE_ForAll)

    veafRadio.refreshRadioMenu()
end

function airAirTraining.initialize()
    airAirTraining.buildRadioMenu()
end

airAirTraining.logInfo(string.format("Loading version %s", airAirTraining.Version))

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

