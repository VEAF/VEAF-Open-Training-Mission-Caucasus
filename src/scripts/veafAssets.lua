-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEAF assets functions for DCS World
-- By zip (2019)
--
-- Features:
-- ---------
-- * manage the assets that roam the map (tankers, awacs, ...)
-- * Works with all current and future maps (Caucasus, NTTR, Normandy, PG, ...)
--
-- Prerequisite:
-- ------------
-- * This script requires DCS 2.5.1 or higher and MIST 4.3.74 or higher.
-- * It also requires the base veaf.lua script library (version 1.0 or higher)
--
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafAssets = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Global settings. Stores the script constants
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Identifier. All output in DCS.log will start with this.
veafAssets.Id = "ASSETS - "

--- Version.
veafAssets.Version = "1.0.3"

veafAssets.Assets = {
    -- list the assets common to all missions below
}

veafAssets.RadioMenuName = "ASSETS (" .. veafAssets.Version .. ")"

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Do not change anything below unless you know what you are doing!
-------------------------------------------------------------------------------------------------------------------------------------------------------------

veafAssets.rootPath = nil

veafAssets.assets = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Utility methods
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafAssets.logInfo(message)
    veaf.logInfo(veafAssets.Id .. message)
end

function veafAssets.logDebug(message)
    veaf.logDebug(veafAssets.Id .. message)
end

function veafAssets.logTrace(message)
    veaf.logTrace(veafAssets.Id .. message)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Radio menu and help
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Build the initial radio menu
function veafAssets.buildRadioMenu()
    veafAssets.rootPath = veafRadio.addSubMenu(veafAssets.RadioMenuName)
    veafRadio.addCommandToSubmenu("HELP", veafAssets.rootPath, veafAssets.help, nil, true)
    for _, asset in pairs(veafAssets.assets) do
        if asset.disposable or asset.information then -- in this case we need a submenu
            local radioMenu = veafRadio.addSubMenu(asset.description, veafAssets.rootPath)
            veafRadio.addCommandToSubmenu("Respawn "..asset.description, radioMenu, veafAssets.respawn, asset.name, false)
            if asset.information then
                veafRadio.addCommandToSubmenu("Get info on "..asset.description, radioMenu, veafAssets.info, asset.name, true)
            end
            if asset.disposable then
                veafRadio.addCommandToSubmenu("Dispose of "..asset.description, radioMenu, veafAssets.dispose, asset.name, false)
            end
        else
            veafRadio.addCommandToSubmenu("Respawn "..asset.description, veafAssets.rootPath, veafAssets.respawn, asset.name, false)
        end
    end
    
    veafRadio.refreshRadioMenu()
end

function veafAssets.info(parameters)
    local name, groupId = unpack(parameters)
    veafAssets.logDebug("veafAssets.info "..name)
    local theAsset = nil
    for _, asset in pairs(veafAssets.assets) do
        if asset.name == name then
            theAsset = asset
        end
    end
    if theAsset then
        local group = Group.getByName(theAsset.name)
        local text = theAsset.description .. " is not active nor alive"
        if group then
            local nAlive = 0
            for _, unit in pairs(group:getUnits()) do
                if unit:getLife() > 0 then
                    nAlive = nAlive + 1
                end
            end
            if nAlive > 0 then
                if nAlive == 1 then
                    text = string.format("%s is active ; one unit is alive\n", theAsset.description)
                else
                    text = string.format("%s is active ; %d units are alive\n", theAsset.description, nAlive)
                end
                if theAsset.information then
                    text = text .. theAsset.information
                end
            end
        end 
        trigger.action.outTextForGroup(groupId, text, 30)
    end
end

function veafAssets.dispose(name)
    veafAssets.logDebug("veafAssets.dispose "..name)
    local theAsset = nil
    for _, asset in pairs(veafAssets.assets) do
        if asset.name == name then
            theAsset = asset
        end
    end
    if theAsset then
        veafAssets.logDebug("veafSpawn.destroy "..theAsset.name)
        local group = Group.getByName(theAsset.name)
        if group then
            for _, unit in pairs(group:getUnits()) do
                Unit.destroy(unit)
            end
        end
        local text = "I've disposed of " .. theAsset.description
        trigger.action.outText(text, 30)
    end
end

function veafAssets.respawn(name)
    veafAssets.logDebug("veafAssets.respawn "..name)
    local theAsset = nil
    for _, asset in pairs(veafAssets.assets) do
        if asset.name == name then
            theAsset = asset
        end
    end
    if theAsset then
        mist.respawnGroup(name, true)
        local text = "I've respawned " .. theAsset.description
        if theAsset.jtac then
            ctld.JTACAutoLase(name, theAsset.jtac, false, "vehicle")
            text = text .. " lasing with code " .. theAsset.jtac
        end
        trigger.action.outText(text, 30)
    end
end


function veafAssets.help(groupId)
    local text =
        'The radio menu lists all the assets, friendly or enemy\n' ..
        'Use these menus to respawn the assets when needed\n'
    trigger.action.outTextForGroup(groupId, text, 30)
end


-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialisation
-------------------------------------------------------------------------------------------------------------------------------------------------------------

function veafAssets.buildAssetsDatabase()
    veafAssets.assets = {}
    for i, v in ipairs(veafAssets.Assets) do
        veafAssets.assets[i] = v
    end
end


function veafAssets.initialize()
    veafAssets.buildAssetsDatabase()
    veafAssets.buildRadioMenu()
    -- start any action-bound asset (e.g. jtacs)
    for name, asset in pairs(veafAssets.assets) do
        if asset.jtac then
            ctld.JTACAutoLase(name, asset.jtac, false, "vehicle")
        end
    end
end

veafAssets.logInfo(string.format("Loading version %s", veafAssets.Version))

--- Enable/Disable error boxes displayed on screen.
env.setErrorMessageBoxEnabled(false)

