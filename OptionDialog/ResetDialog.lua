---@class addonTableGatherOverview
local addonTable = select(2, ...)

local expressway = "Interface\\AddOns\\GatherOverview\\Assets\\Fonts\\Expressway.TTF"

function addonTable.OptionDialog.ShowResetWarningDialog()
    -- Get player class color
    local _, classFilename = UnitClass("player")
    local classColor = RAID_CLASS_COLORS[classFilename]
    local r, g, b = classColor.r, classColor.g, classColor.b
    
    -- Create main dialog frame (no backdrop/border)
    local dialog = CreateFrame("Frame", "GatherOverviewResetDialog", UIParent)
    dialog:SetSize(500, 280)
    dialog:SetPoint("CENTER")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    
    -- Create addon name title with class color and Expressway font
    local addonTitle = dialog:CreateFontString(nil, "ARTWORK")
    addonTitle:SetFont(expressway, 20, "OUTLINE")
    addonTitle:SetPoint("TOPLEFT", dialog, "TOPLEFT", 20, -15)
    addonTitle:SetText(addonTable.Locales.GATHER_OVERVIEW)
    addonTitle:SetTextColor(r, g, b)
    
    -- Create top separator line with class color
    local topSeparator = dialog:CreateLine(nil, "ARTWORK")
    topSeparator:SetStartPoint("TOPLEFT", 20, -40)
    topSeparator:SetEndPoint("TOPRIGHT", -20, -40)
    topSeparator:SetThickness(1)
    topSeparator:SetColorTexture(r, g, b, 1)
    
    -- Create message text with class color and Expressway font
    local text = dialog:CreateFontString(nil, "ARTWORK")
    text:SetFont(expressway, 12, "")
    text:SetPoint("TOPLEFT", dialog, "TOPLEFT", 20, -65)
    text:SetPoint("TOPRIGHT", dialog, "TOPRIGHT", -20, -65)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetNonSpaceWrap(true)
    text:SetHeight(100)
    text:SetText(addonTable.Locales.RESET_ALL_PROFILES_TEXT)
    text:SetTextColor(r, g, b)
    
    -- Create bottom separator line with class color
    local bottomSeparator = dialog:CreateLine(nil, "ARTWORK")
    bottomSeparator:SetStartPoint("TOPLEFT", 20, -175)
    bottomSeparator:SetEndPoint("TOPRIGHT", -20, -175)
    bottomSeparator:SetThickness(1)
    bottomSeparator:SetColorTexture(r, g, b, 1)
    
    -- Create OK button
    local okButton = CreateFrame("Button", nil, dialog, "BackdropTemplate")
    okButton:SetSize(100, 30)
    okButton:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 20)
    
    -- Set button backdrop with class color border
    okButton:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8x8",
        edgeFile = "Interface/Buttons/WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    okButton:SetBackdropColor(0, 0, 0, 1)
    okButton:SetBackdropBorderColor(r, g, b, 1)
    
    -- Create button text with class color and Expressway font
    local buttonText = okButton:CreateFontString(nil, "OVERLAY")
    buttonText:SetFont(expressway, 14, "OUTLINE")
    buttonText:SetPoint("CENTER", okButton, "CENTER", 0, 0)
    buttonText:SetText("OK")
    buttonText:SetTextColor(r, g, b, 1)
    
    -- Button hover effects
    okButton:SetScript("OnEnter", function()
        okButton:SetBackdropColor(r, g, b, 1)
        buttonText:SetTextColor(0, 0, 0, 1)
    end)
    
    okButton:SetScript("OnLeave", function()
        okButton:SetBackdropColor(0, 0, 0, 1)
        buttonText:SetTextColor(r, g, b, 1)
    end)
    
    okButton:SetScript("OnClick", function()
        -- Reset all profiles
        addonTable.Config.ResetProfile()
        -- Close dialog
        dialog:Hide()
        dialog = nil
        -- Reload UI
        C_UI.Reload()
    end)
    
    dialog:Show()
end

addonTable.OptionDialog.ShowResetWarningDialog = addonTable.OptionDialog.ShowResetWarningDialog
