---@class addonTableGatherOverview
local addonTable = select(2, ...)

function addonTable.Core.Initialize()
  addonTable.Utilities.Message(addonTable.Locales.WELCOME_MSG)
  local version = C_AddOns.GetAddOnMetadata("GatherOverview", "Version")
  addonTable.Utilities.Message(addonTable.Locales.VERSION .. ":".. version)
  addonTable.Utilities.Message(addonTable.Locales.TO_OPEN_OPTIONS_X)
  -- Initialization code goes here
  addonTable.Config.InitializeData()
  addonTable.Core.UpdateProfessionEnabled()  -- Update Enabled Professions on start
  addonTable.SlashCmd.Initialize()
  addonTable.OptionDialog.Initialize()
  addonTable.MainFrame.Initialize()
end

function addonTable.Core.UpdateProfessionEnabled()
    local learnedProfessions = {}
    for _, profIndex in pairs({GetProfessions()}) do
      local name = GetProfessionInfo(profIndex)
      learnedProfessions[name] = true
	  end
    
    local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    for _, prof in pairs(professionsConfig) do
        prof.enabled = learnedProfessions[prof.name] or false
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("SKILL_LINES_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("PLAYER_UPDATE_RESTING")
frame:SetScript("OnEvent", function(_, eventName, data)
  if eventName == "ADDON_LOADED" and data == "GatherOverview" then
    addonTable.Core.Initialize()
  elseif eventName == "SKILL_LINES_CHANGED" then
    -- Profession skill change
    addonTable.Core.UpdateProfessionEnabled()
  elseif eventName == "ZONE_CHANGED_NEW_AREA" or eventName == "PLAYER_UPDATE_RESTING" then
    -- Player change zone
    addonTable.MainFrame.ToggleIfNeeded()
  elseif eventName == "BAG_UPDATE_DELAYED" or eventName == "PLAYER_LOGIN" then
    addonTable.MainFrame.ScanBags()
    -- Update Item count display
    addonTable.MainFrame.UpdateUI()
  end
end)