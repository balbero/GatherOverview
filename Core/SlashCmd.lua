---@class addonTableGatherOverview
local addonTable = select(2, ...)
addonTable.SlashCmd = {}

function addonTable.SlashCmd.Initialize()
  SlashCmdList["GatherOverview"] = addonTable.SlashCmd.Handler
  SLASH_GatherOverview1 = "/gatheroverview"
  SLASH_GatherOverview2 = "/gatover"
end

function addonTable.SlashCmd.Reset()
  GATHEROVERVIEW_CONFIG = nil
  ReloadUI()
end

function addonTable.SlashCmd.CustomiseUI()

  if addonTable.OptionDialog.ABOUT then
    if Settings then
      local id = addonTable.OptionDialog.ABOUT.category:GetID()
      Settings.OpenToCategory(id)
    else
        InterfaceOptionsFrame_OpenToCategory(addonTable.Locales.GATHER_OVERVIEW)
    end
  end
end

local COMMANDS = {
  [""] = addonTable.SlashCmd.CustomiseUI,
  ["reset"] = addonTable.SlashCmd.Reset,
  [addonTable.Locales.SLASH_RESET] = addonTable.SlashCmd.Reset,
}
local HELP = {
  {"", addonTable.Locales.SLASH_HELP},
  {addonTable.Locales.SLASH_RESET, addonTable.Locales.SLASH_RESET_HELP},
}

function addonTable.SlashCmd.Handler(input)
  local split = {strsplit("\a", (input:gsub("%s+","\a")))}
  
  local root = split[1]
  if COMMANDS[root] ~= nil then
    table.remove(split, 1)
    COMMANDS[root](unpack(split))
  else
    if root ~= "help" and root ~= "h" then
      addonTable.Utilities.Message(addonTable.Locales.SLASH_UNKNOWN_COMMAND:format(root))
    end

    for _, entry in ipairs(HELP) do
      if entry[1] == "" then
        addonTable.Utilities.Message("/gatover - " .. entry[2])
      else
        addonTable.Utilities.Message("/gatover " .. entry[1] .. " - " .. entry[2])
      end
    end
  end
end