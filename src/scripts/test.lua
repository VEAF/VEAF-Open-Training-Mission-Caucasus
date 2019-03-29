mist = {}
mist.utils = {}

--- Converts angle in degrees to radians.
-- @param angle angle in degrees
-- @return angle in degrees
function mist.utils.toRadian(angle)
    return angle*math.pi/180
end

	function mist.utils.toDegree(angle)
		return angle*180/math.pi
	end

veaf = {}
math.randomseed(os.time())
--- Identifier. All output in DCS.log will start with this.
veaf.Id = "VEAF - "

--- Version.
veaf.Version = "1.1.1"

--- Development version ?
veaf.Development = true

--- Enable logDebug ==> give more output to DCS log file.
veaf.Debug = veaf.Development
--- Enable logTrace ==> give even more output to DCS log file.
veaf.Trace = veaf.Development

veaf.RadioMenuName = "VEAF"

function veaf.logInfo(text)
  print("INFO VEAF - " .. text)
end

function veaf.logDebug(text)
  print("DEBUG VEAF - " .. text)
end

function veaf.logTrace(text)
  print("TRACE VEAF - " .. text)
end

function veaf.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

dofile("scripts/veafRadio.lua")

function veafRadio.buildHumanGroups()
  veafRadio.logInfo("buildHumanGroups()")
end

missionCommands = {}
function missionCommands.addSubMenu(title, path)
  veafRadio.logInfo("addSubMenu() " .. title)
end

function missionCommands.addCommand(title, dcsRadioMenu, method)
  veafRadio.logInfo("addCommand() " .. title)
end

function missionCommands.removeItem(item)
  veafRadio.logInfo("removeItem()")
end

veafRadio.initialize()


function test1()
  veaf.logInfo(test1)
end

function test2()
  veaf.logInfo(test2)
end

local casRadioMenu = veafRadio.addSubMenu("VEAF CAS MISSION")
veafRadio.addCommandToSubmenu("HELP",casRadioMenu,veaf.emptyFunction)
local cas_Markers_RadioMenu = veafRadio.addSubMenu("Markers",casRadioMenu)
veafRadio.addCommandToSubmenu("Smoke",cas_Markers_RadioMenu,veaf.emptyFunction)
veafRadio.refreshRadioMenu()