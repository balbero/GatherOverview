---@class addonTableGatherOverview
local addonTable = select(2, ...)

local optionsFrame = CreateFrame("Frame", addonTable.Locales.GATHER_OVERVIEW .. "AboutPanel", InterfaceOptionsFramePanelContainer)
optionsFrame.name = addonTable.Locales.GATHER_OVERVIEW
optionsFrame:Hide()

function addonTable.OptionDialog.SetInfo(frame, anchor, titleText, val)
  local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  title:SetWidth(75)
  if not anchor then title:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -16)
  else title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6) end
  title:SetJustifyH("RIGHT")
  title:SetText(titleText..":")

  local detail = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  detail:SetPoint("LEFT", title, "RIGHT", 4, 0)
  detail:SetPoint("RIGHT", -16, 0)
  detail:SetJustifyH("LEFT")
  detail:SetText(val)

  return title
end

function addonTable.OptionDialog.Initialize()

  local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText(addonTable.Locales.GATHER_OVERVIEW)

  local subtitle = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  subtitle:SetHeight(32)
  subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  subtitle:SetPoint("RIGHT", optionsFrame, -32, 0)
  subtitle:SetNonSpaceWrap(true)
  subtitle:SetJustifyH("LEFT")
  subtitle:SetJustifyV("TOP")
  subtitle:SetText(addonTable.Locales.ADDON_DESCRIPTION)

  local version = C_AddOns.GetAddOnMetadata("GatherOverview", "Version")
  local versionText = addonTable.OptionDialog.SetInfo(optionsFrame, subtitle, addonTable.Locales.VERSION, version)
  local authorText = addonTable.OptionDialog.SetInfo(optionsFrame, versionText, addonTable.Locales.AUTHOR, addonTable.Locales.BY_FAELGORN)
  addonTable.OptionDialog.SetInfo(optionsFrame, authorText, addonTable.Locales.REALM, addonTable.Locales.REALM_NAME)
  
end

addonTable.OptionDialog.ABOUT = optionsFrame

optionsFrame:SetScript("OnShow", addonTable.OptionDialog.Initialize)
optionsFrame:Hide()

-- Register the options panel as a Category in the Addon panel
local category, layout = Settings.RegisterCanvasLayoutCategory(optionsFrame, addonTable.Locales.GATHER_OVERVIEW)
category.ID = addonTable.Locales.GATHER_OVERVIEW
Settings.RegisterAddOnCategory(category)
addonTable.OptionDialog.ABOUT.category = category
addonTable.OptionDialog.ABOUT.layout = layout
