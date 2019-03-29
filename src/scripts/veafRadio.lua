-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF radio menu script library for DCS Workd
-- By zip (2018)
--
-- Features:
-- ---------
-- Manage the VEAF radio menus in the F10 - Other menu
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires the base veaf.lua script library (version 1.0 or higher)
--
-- Load the script:
-- ----------------
-- 1.) Download the script and save it anywhere on your hard drive.
-- 2.) Open your mission in the mission editor.
-- 3.) Add a new trigger:
--     * TYPE   "4 MISSION START"
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of MIST and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of veaf.lua and click OK.
--     * ACTION "DO SCRIPT FILE"
--     * OPEN --> Browse to the location of this script and click OK.
--     * ACTION "DO SCRIPT"
--     * set the script command to "veafRadio.initialize()" and click OK.
-- 4.) Save the mission and start it.
-- 5.) Have fun :)
--
-- Basic Usage:
-- ------------
-- TODO
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- veafRadio Table.
veafRadio = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafRadio.Id = "RADIO - "

--- Version.
veafRadio.Version = "1.0.3"

veafRadio.RadioMenuName = "VEAF (" .. veaf.Version .. " - radio " .. veafRadio.Version .. ")"

--- Number of seconds between each automatic rebuild of the radio menu
veafRadio.SecondsBetweenRadioMenuAutomaticRebuild = 600 -- 10 minutes ; should not be necessary as the menu is refreshed when a human enters a unit

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Humans Groups (associative array groupId => group)
veafRadio.humanGroups = {}

--- This structure contains all the radio menus
veafRadio.radioMenu = {}
veafRadio.radioMenu.title = veafRadio.RadioMenuName
veafRadio.radioMenu.dcsRadioMenu = nil
veafRadio.radioMenu.subMenus = {}
veafRadio.radioMenu.commands = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafRadio.logError(message)
  veaf.logError(veafRadio.Id .. message)
end

function veafRadio.logInfo(message)
    veaf.logInfo(veafRadio.Id .. message)
end

function veafRadio.logDebug(message)
    veaf.logDebug(veafRadio.Id .. message)
end

function veafRadio.logTrace(message)
    veaf.logTrace(veafRadio.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event handler.
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Event handler.
veafRadio.eventHandler = {}

--- Handle world events.
function veafRadio.eventHandler:onEvent(Event)

  -- Only interested in S_EVENT_PLAYER_ENTER_UNIT
  if Event == nil or not Event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT  then
      return true
  end

  -- Debug output.
  if Event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
    veafRadio.logDebug("S_EVENT_PLAYER_ENTER_UNIT")
    veafRadio.logTrace(string.format("Event id        = %s", tostring(Event.id)))
    veafRadio.logTrace(string.format("Event time      = %s", tostring(Event.time)))
    veafRadio.logTrace(string.format("Event idx       = %s", tostring(Event.idx)))
    veafRadio.logTrace(string.format("Event coalition = %s", tostring(Event.coalition)))
    veafRadio.logTrace(string.format("Event group id  = %s", tostring(Event.groupID)))
    if Event.initiator ~= nil then
        local _unitname = Event.initiator:getName()
        veafRadio.logTrace(string.format("Event ini unit  = %s", tostring(_unitname)))
    end
    veafRadio.logTrace(string.format("Event text      = \n%s", tostring(Event.text)))

    -- refresh the radio menu
    -- TODO refresh it only for this player ? Is this even possible ?
    veafRadio.refreshRadioMenu()
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Refresh the radio menu, based on stored information
--- This is called from another method that has first changed the radio menu information by adding or removing elements
function veafRadio.refreshRadioMenu()
  -- completely delete the dcs radio menu
  veafRadio.logTrace("completely delete the dcs radio menu")
  if veafRadio.radioMenu.dcsRadioMenu then
    missionCommands.removeItem(veafRadio.radioMenu.dcsRadioMenu)
  else
    veafRadio.logInfo("refreshRadioMenu() first time : no DCS radio menu yet")
  end
  
  -- create all the commands and submenus in the dcs radio menu
  veafRadio.logTrace("create all the commands and submenus in the dcs radio menu")
  veafRadio.refreshRadioSubmenu(nil, veafRadio.radioMenu)        
end

function veafRadio.refreshRadioSubmenu(parentRadioMenu, radioMenu)
  veafRadio.logTrace("veafRadio.refreshRadioSubmenu "..radioMenu.title)
  -- create the radio menu in DCS
  if parentRadioMenu then
    radioMenu.dcsRadioMenu = missionCommands.addSubMenu(radioMenu.title, parentRadioMenu.dcsRadioMenu)
  else
    radioMenu.dcsRadioMenu = missionCommands.addSubMenu(radioMenu.title)
  end
  
  -- create the commands in the radio menu
  for count = 1,#radioMenu.commands do
    local command = radioMenu.commands[count]
    if command.isForGroup then
      -- build menu for each player
      for groupId, group in pairs(veafRadio.humanGroups) do
          -- add radio command by player group
          local parameters = command.parameters
          if parameters == nil then
            parameters = groupId
          else
            parameters = { command.parameters }
            table.insert(parameters, groupId)
          end 
          missionCommands.addCommandForGroup(groupId, command.title, radioMenu.dcsRadioMenu, command.method, parameters)
      end
    else
      if not command.method then
        veafRadio.logError("ERROR - missing method for command " .. command.title)
      end
      missionCommands.addCommand(command.title, radioMenu.dcsRadioMenu, command.method, command.parameters)
    end
  end
  
  -- recurse to create the submenus in the radio menu
  for count = 1,#radioMenu.subMenus do
    local subMenu = radioMenu.subMenus[count]
    veafRadio.refreshRadioSubmenu(radioMenu, subMenu)
  end
end

function veafRadio.addCommandToMainMenu(title, method)
  return veafRadio.addCommandToSubmenu(title, nil, method)
end
  
function veafRadio.addCommandToSubmenu(title, radioMenu, method, parameters, isForGroup)
    local command = {}
    command.title = title
    command.method = method
    command.parameters = parameters
    command.isForGroup = isForGroup
    local menu = veafRadio.radioMenu
    if radioMenu then
       menu = radioMenu 
    end
    
    -- add command to menu
    table.insert(menu.commands, command)
    
    return command
end

function veafRadio.delCommand(radioMenu, title)
  for count = 1,#radioMenu.commands do
    local command = radioMenu.commands[count]
    if command.title == title then
      table.remove(radioMenu.commands, count)
      return true
    end
  end
  
  return false
end

function veafRadio.addMenu(title)
  return veafRadio.addSubMenu(title, nil)
end

function veafRadio.addSubMenu(title, radioMenu)
    local subMenu = {}
    subMenu.title = title
    subMenu.dcsRadioMenu = nil
    subMenu.subMenus = {}
    subMenu.commands = {}
    
    local menu = veafRadio.radioMenu
    if radioMenu then
       menu = radioMenu 
    end
    
    -- add subMenu to menu
    table.insert(menu.subMenus, subMenu)
    
    return subMenu
end

function veafRadio.delSubmenu(subMenu, radioMenu)
  local menu = veafRadio.radioMenu
  if radioMenu then
     menu = radioMenu 
  end
  for count = 1,#menu.subMenus do
    local menu = menu.subMenus[count]
    local found = false
    if type(subMenu) == "string" then
      found = menu.title == subMenu
    else
      found = menu == subMenu
    end
    if found then
      table.remove(menu.subMenus, count)
      return true
    end
  end
  
  return false
end

-- prepare humans groups
function veafRadio.buildHumanGroups() -- TODO make this player-centric, not group-centric

    veafRadio.humanGroups = {}

    -- build menu for each player
    for name, unit in pairs(mist.DBs.humansByName) do
        -- not already in groups list ?
        if veafRadio.humanGroups[unit.groupName] == nil then
            veafRadio.logTrace(string.format("human player found name=%s, groupName=%s", name, unit.groupName))
            veafRadio.humanGroups[unit.groupId] = unit.groupName
        end
    end
end

function veafRadio.radioRefreshWatchdog()
  veafRadio.logDebug("veafRadio.radioRefreshWatchdog()")
  -- refresh the menu
  veafRadio.refreshRadioMenu()

  veafRadio.logDebug("veafRadio.radioRefreshWatchdog() - rescheduling in "..veafRadio.SecondsBetweenRadioMenuAutomaticRebuild)
  -- reschedule
  mist.scheduleFunction(veafRadio.radioRefreshWatchdog,{},timer.getTime()+veafRadio.SecondsBetweenRadioMenuAutomaticRebuild)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafRadio.initialize()
    -- Build the initial radio menu
    veafRadio.buildHumanGroups()
    veafRadio.refreshRadioMenu()
    --veafRadio.radioRefreshWatchdog()

    -- Add "player enter unit" event handler.
    world.addEventHandler(veafRadio.eventHandler)
end

veafRadio.logInfo(string.format("Loading version %s", veafRadio.Version))

