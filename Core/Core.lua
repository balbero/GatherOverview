---@class addonTableGatherOverview
local AddonName, addonTable, _ = ...

local learnedProfessions = {}
addonTable.Core.learnedProfessions = learnedProfessions

local L = addonTable.Locales

function addonTable.Core.UpdateProfessionEnabled()
    local prof1, prof2, _, fishing = GetProfessions()

    wipe(learnedProfessions)

    local professionIndexes = { prof1, prof2, fishing }

    for index = 1, #professionIndexes do
        local profIndex = professionIndexes[index]

        if profIndex then
            local name = GetProfessionInfo(profIndex)

            if name then
                learnedProfessions[name] = true
            end
        end
    end

    learnedProfessions[L.OTHER_STUFF] = true

    local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)

    for _, prof in pairs(professionsConfig) do
        prof.enabled = learnedProfessions[prof.name] or false
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")


local EventHandler = {}

events:SetScript("OnEvent", function(_, event, ...)
  EventHandler[event](...)
end)


function EventHandler.ADDON_LOADED(loadedAddonName, _)
  if loadedAddonName ~= AddonName then return end

  addonTable.Utilities.Message(L.WELCOME_MSG)
  local version = C_AddOns.GetAddOnMetadata("GatherOverview", "Version")
  addonTable.Utilities.Message(L.VERSION .. ":".. version)
  addonTable.Utilities.Message(L.TO_OPEN_OPTIONS_X)
  -- Initialization code goes here
  addonTable.InitializeItems()  -- Initialize Item instances from ItemDB
  addonTable.Config.InitializeData()
  addonTable.SlashCmd.Initialize()
  addonTable.OptionDialog.Initialize()
  events:UnregisterEvent("ADDON_LOADED") -- no need to keep tracking the event
end

function EventHandler.PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi, _)
  if not (isInitialLogin or isReloadingUi) then return end

  addonTable.Core.UpdateProfessionEnabled()  -- Update Enabled Professions on start
  addonTable.MainFrame.Initialize()

  events:RegisterEvent("SKILL_LINES_CHANGED")
  events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  events:RegisterEvent("BAG_UPDATE_DELAYED")
  events:RegisterEvent("PLAYER_UPDATE_RESTING")
  events:RegisterEvent("PLAYER_REGEN_DISABLED")
  events:RegisterEvent("PLAYER_REGEN_ENABLED")

  events:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function EventHandler.SKILL_LINES_CHANGED()
  addonTable.Core.UpdateProfessionEnabled()
  addonTable.MainFrame.UpdateUI()
end

function EventHandler.ZONE_CHANGED_NEW_AREA()
  addonTable.MainFrame.UpdateUI()
end

function EventHandler.PLAYER_UPDATE_RESTING()
  addonTable.MainFrame.UpdateUI()
end

function EventHandler.PLAYER_REGEN_DISABLED()
  addonTable.MainFrame.UpdateUI()
end

function EventHandler.PLAYER_REGEN_ENABLED()
  addonTable.MainFrame.UpdateUI()
end

function EventHandler.BAG_UPDATE_DELAYED()
  addonTable.MainFrame.ScanBags()
  addonTable.MainFrame.UpdateUI()
end