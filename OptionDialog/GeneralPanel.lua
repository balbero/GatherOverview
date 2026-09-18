---@class addonTableGatherOverview
local addonTable = select(2, ...)

local L = addonTable.Locales

local AceGUI = LibStub("AceGUI-3.0")

local panel = AceGUI:Create("BlizOptionsGroup")
panel:SetTitle(L.GENERAL)

panel:SetCallback("okay", function()
    addonTable.MainFrame.UpdateUI()
end)
panel:SetCallback("refresh", function()
    panel.refresh()
    addonTable.MainFrame.UpdateUI()
end)
panel:SetCallback("OnShow", function()
    if not panel.initialized then
        panel:SetupGeneral()
        panel.refresh()
    end
end)

local FONTS             = "Interface\\AddOns\\GatherOverview\\Assets\\Fonts\\"

local FONT_LIST = {
    { name = "Friz Quadrata", path = "Fonts\\FRIZQT__.TTF" },
    { name = "Morpheus",      path = "Fonts\\MORPHEUS.ttf" },
    { name = "Skurri",        path = "Fonts\\SKURRI.ttf" },
    { name = "Arial",         path = "Fonts\\ARIALN.ttf" },
    { name = "ExpressWay",    path = FONTS.."ExpressWay.TTF"}
}

local FONT_SIZES = {}
for i = 6, 15 do
    FONT_SIZES[i] = i
end

addonTable.OptionDialog.GENERAL = panel

function panel:GetOptionInsetPanel()
    local optionsInset = AceGUI:Create("InlineGroup")
    optionsInset:SetTitle(L.OPTION_DISPLAY)
    optionsInset:SetFullWidth(true)
    do
        self.showTotal = AceGUI:Create("CheckBox")
        self.showTotal.message = {
            name = L.SHOW_TOTAL,
            description = L.SHOW_TOTAL_SUB
        }
        self.showTotal:SetFullWidth(true)
        self.showTotal:SetLabel(L.SHOW_TOTAL)
        self.showTotal:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOTAL))
        self.showTotal:SetCallback("OnValueChanged", function(_, _, value)
            addonTable.Config.Set(addonTable.Config.Options.SHOW_TOTAL, value)
            addonTable.MainFrame.UpdateUI()
        end)
        self.showTotal:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
        self.showTotal:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
        optionsInset:AddChild(self.showTotal)

        local fontGroup = AceGUI:Create("SimpleGroup")
        fontGroup:SetFullWidth(true)
        fontGroup:SetLayout("Flow")

        self.fontNameDropDown = AceGUI:Create("Dropdown")
        self.fontNameDropDown:SetLabel(L.SELECT_FONT)
        self.fontNameDropDown:SetWidth(200)
        self.fontNameDropDown:SetMultiselect(false)
        local fontNames = {}
        for _, f in ipairs(FONT_LIST) do
            fontNames[f.name] = f.name
        end
        self.fontNameDropDown:SetList(fontNames)
        self.fontNameDropDown:SetValue(addonTable.Config.Get(addonTable.Config.Options.FONT).name)

        self.fontNameDropDown:SetCallback("OnValueChanged", function(_, _, key)
            for _, f in ipairs(FONT_LIST) do
                if f.name == key then
                    addonTable.Config.Set(addonTable.Config.Options.FONT, f)
                    addonTable.MainFrame.UpdateUI()
                    break
                end
            end
        end)
        fontGroup:AddChild(self.fontNameDropDown)

        self.fontSizeDropDown = AceGUI:Create("Dropdown")
        self.fontSizeDropDown:SetLabel(L.SELECT_FONT_SIZE)
        self.fontSizeDropDown:SetWidth(200)
        self.fontSizeDropDown:SetMultiselect(false)
        self.fontSizeDropDown:SetList(FONT_SIZES)
        self.fontSizeDropDown:SetValue(addonTable.Config.Get(addonTable.Config.Options.FONT_SIZE))

        self.fontSizeDropDown:SetCallback("OnValueChanged", function(_, _, key)
            addonTable.Config.Set(addonTable.Config.Options.FONT_SIZE, key)
            addonTable.MainFrame.UpdateUI()
        end)
        fontGroup:AddChild(self.fontSizeDropDown)

        optionsInset:AddChild(fontGroup)
    end

    return optionsInset
end

function panel:SetupGeneral()
    panel.initialized = true

    local scrollPanel = AceGUI:Create("ScrollFrame")
    scrollPanel:SetFullHeight(true)
    scrollPanel:SetFullWidth(true)
    -- Section for options
    local optionsInset = self:GetOptionInsetPanel()
    scrollPanel:AddChild(optionsInset)

    local separator = AceGUI:Create("Heading")
    separator:SetText("")
    separator:SetFullWidth(true)
    separator:SetHeight(2)
    self:AddChild(separator)

    local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    local professionsInset = AceGUI:Create("InlineGroup")
    professionsInset:SetTitle(L.PROFESSIONS)
    professionsInset:SetFullWidth(true)

    local iconPerRowGroup = AceGUI:Create("SimpleGroup")
    iconPerRowGroup:SetFullWidth(true)
    iconPerRowGroup:SetLayout("Flow")
    self.iconPerRowSlider = AceGUI:Create("Slider")
    self.iconPerRowSlider:SetWidth(150)
    self.iconPerRowSlider:SetSliderValues(2, 12, 1)
    self.iconPerRowSlider:SetLabel(L.ROW_AMOUNT)
    self.iconPerRowSlider:SetValue(addonTable.Config.Get(addonTable.Config.Options.ROW_AMOUNT))
    self.iconPerRowSlider:SetCallback("OnMouseUp", function(_,_, value)
        addonTable.Config.Set(addonTable.Config.Options.ROW_AMOUNT, value)
        addonTable.MainFrame.UpdateUI()
    end)
    iconPerRowGroup:AddChild(self.iconPerRowSlider)
    professionsInset:AddChild(iconPerRowGroup)
    
    professionsInset:AddChild(addonTable.Components.GetVSpace(5))

    local separator = AceGUI:Create("Heading")
    separator:SetText("")
    separator:SetFullWidth(true)
    separator:SetHeight(2)
    professionsInset:AddChild(separator)
    
    professionsInset:AddChild(addonTable.Components.GetVSpace(5))

    for _, p in pairs(professionsConfig) do
	    self.prof = {}
        local profContainer = AceGUI:Create("SimpleGroup")
        profContainer:SetFullWidth(true)
        profContainer:SetLayout("List")

        local profLabel = AceGUI:Create("Label")
        profLabel:SetColor(0.98, 0.82, 0, 1)
        profLabel:SetText(addonTable.Config.GetProfessionNameFromIndex(p.current_profession))
        profLabel:SetFullWidth(true)
        profContainer:AddChild(profLabel)
        
        -- Show in instance
        self.prof.showInInstance = AceGUI:Create("CheckBox")
        self.prof.showInInstance.message = {
            name = L.SHOW_IN_INSTANCES,
            description = L.SHOW_IN_INSTANCES_SUB
        }
        self.prof.showInInstance:SetFullWidth(true)
        self.prof.showInInstance:SetLabel(L.SHOW_IN_INSTANCES)
        self.prof.showInInstance:SetValue(p.showInInstance)
        self.prof.showInInstance:SetCallback("OnValueChanged", function(_, _, value)
            if not p then p = {} end
            p.showInInstance = value
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        self.prof.showInInstance:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
        self.prof.showInInstance:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
        profContainer:AddChild(self.prof.showInInstance)

        -- Show in rest zone
        self.prof.displayInRestZone = AceGUI:Create("CheckBox")
        self.prof.displayInRestZone.message = {
            name = L.DISPLAY_IN_REPO_ZONE,
            description = L.DISPLAY_IN_REPO_ZONE_SUB
        }
        self.prof.displayInRestZone:SetFullWidth(true)
        self.prof.displayInRestZone:SetLabel(L.DISPLAY_IN_REPO_ZONE)
        self.prof.displayInRestZone:SetValue(p.showInRestingZone)
        self.prof.displayInRestZone:SetCallback("OnValueChanged", function(_, _, value)
            if not p then p = {} end
            p.showInRestingZone = value
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        self.prof.displayInRestZone:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
        self.prof.displayInRestZone:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
        profContainer:AddChild(self.prof.displayInRestZone)

        -- Show in combat
        self.prof.showInCombat = AceGUI:Create("CheckBox")
        self.prof.showInCombat.message = {
            name = L.SHOW_IN_COMBAT,
            description = L.SHOW_IN_COMBAT_SUB
        }
        self.prof.showInCombat:SetFullWidth(true)
        self.prof.showInCombat:SetLabel(L.SHOW_IN_COMBAT)
        self.prof.showInCombat:SetValue(p.showDuringCombat)
        self.prof.showInCombat:SetCallback("OnValueChanged", function(_, _, value)
            if not p then p = {} end
            p.showDuringCombat = value
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        self.prof.showInCombat:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
        self.prof.showInCombat:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
        profContainer:AddChild(self.prof.showInCombat)

        local iconSizeGroup = AceGUI:Create("SimpleGroup")
        iconSizeGroup:SetFullWidth(true)
        iconSizeGroup:SetLayout("Flow")
        local iconSizeLabel = AceGUI:Create("Label")
        iconSizeLabel:SetText(L.ICON_SIZE)
        iconSizeGroup:AddChild(iconSizeLabel)
        self.prof.iconWidthSlider = AceGUI:Create("Slider")
        self.prof.iconWidthSlider:SetWidth(150)
        self.prof.iconWidthSlider:SetSliderValues(16, 64, 1)
        self.prof.iconWidthSlider:SetLabel(L.WIDTH)
        self.prof.iconWidthSlider:SetValue(p.icon_width or addonTable.Config.Get(addonTable.Config.Options.ICON_WIDTH))
        self.prof.iconWidthSlider:SetCallback("OnMouseUp", function(_,_, value)
            if not p then p = {} end
            p.icon_width = value
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        iconSizeGroup:AddChild(self.prof.iconWidthSlider)
        self.prof.iconHeightSlider = AceGUI:Create("Slider")
        self.prof.iconHeightSlider:SetWidth(150)
        self.prof.iconHeightSlider:SetSliderValues(16, 64, 1)
        self.prof.iconHeightSlider:SetLabel(L.HEIGHT)
        self.prof.iconHeightSlider:SetValue(p.icon_height or addonTable.Config.Get(addonTable.Config.Options.ICON_HEIGHT))
        self.prof.iconHeightSlider:SetCallback("OnMouseUp", function(_,_, value)
            if not p then p = {} end
            p.icon_height = value
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        iconSizeGroup:AddChild(self.prof.iconHeightSlider)
        profContainer:AddChild(iconSizeGroup)
        
        -- Low Threshold input for this profession
        local profLowContainer = addonTable.Components.GetLowThresholdAndColorPickerGroup(self, p)
        profContainer:AddChild(profLowContainer)

        -- Median Threshold Color for this profession
        local profMedContainer = AceGUI:Create("SimpleGroup")
        profMedContainer:SetFullWidth(true)
        profMedContainer:SetLayout("Flow")

        profMedContainer:AddChild(addonTable.Components.GetHSpace(177)) -- space before threshold label + threshold label width + edit box width + space after editbox
        
        self.prof.medColorFrame = AceGUI:Create("ColorPicker")
        local med_color = p.medium_color or addonTable.Config.Get(addonTable.Config.Options.MEDIUM_THRESHOLD_COLOR)
        self.prof.medColorFrame:SetLabel(L.MEDIUM_COLOR)
        self.prof.medColorFrame:SetColor(med_color.r, med_color.g, med_color.b, med_color.a)
        self.prof.medColorFrame:SetCallback("OnValueChanged",  function(_, _, newr, newg, newb, newa)
            if not p then p = {} end
            if p.medium_color ~= nil and p.medium_color == {r = newr, g = newg, b = newb, a = newa} then return end
            p.medium_color = {r = newr, g = newg, b = newb, a = newa}
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        profMedContainer:AddChild(self.prof.medColorFrame)
        profContainer:AddChild(profMedContainer)

        -- High Threshold input for this profession
        local profHighContainer = addonTable.Components.GetHighThresholdAndColorPickerGroup(self, p)
        profContainer:AddChild(profHighContainer)

        local profSeparator = AceGUI:Create("Heading")
        profSeparator:SetText("")
        profSeparator:SetFullWidth(true)
        profSeparator:SetHeight(14)
        profContainer:AddChild(profSeparator)


        professionsInset:AddChild(profContainer)
    end
    scrollPanel:AddChild(professionsInset)

    self:AddChild(scrollPanel)
end

function panel.refresh()
    xpcall(function()

        if not panel.initialized then
            panel:SetupGeneral()
        end

        local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
        panel.showTotal:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOTAL))
        panel.iconPerRowSlider:SetValue(addonTable.Config.Get(addonTable.Config.Options.ROW_AMOUNT))
        for _, prof in ipairs(professionsConfig) do
            if panel.prof.iconWidthSlider then
                panel.prof.iconWidthSlider:SetValue(prof.icon_width or addonTable.Config.Get(addonTable.Config.Options.ICON_WIDTH))
            end
            if panel.prof.iconHeightSlider then
                panel.prof.iconHeightSlider:SetValue(prof.icon_height or addonTable.Config.Get(addonTable.Config.Options.ICON_HEIGHT))
            end
            if panel.prof.lowThresholdInput then
                panel.prof.lowThresholdInput:SetText(tostring(prof and prof.low or 50))
            end
            if panel.prof.highThresholdInput then
                panel.prof.highThresholdInput:SetText(tostring(prof and prof.high or 100))
            end
            if panel.prof.lowColorFrame then
                local lowColor = addonTable.Config.Get(addonTable.Config.Options.LOW_THRESHOLD_COLOR)
                if prof then
                    lowColor = prof.low_color or lowColor
                end
                panel.prof.lowColorFrame:SetColor(lowColor.r, lowColor.g, lowColor.b, lowColor.a)
            end
            if panel.prof.medColorFrame then
                local med_color = addonTable.Config.Get(addonTable.Config.Options.MEDIUM_THRESHOLD_COLOR)
                if prof then
                    med_color = prof.medium_color or med_color
                end
                panel.prof.medColorFrame:SetColor(med_color.r, med_color.g, med_color.b, med_color.a)
            end
            if panel.prof.highColorFrame then
                local high_color = addonTable.Config.Get(addonTable.Config.Options.HIGH_THRESHOLD_COLOR)
                if prof then
                    high_color = prof.high_color or high_color
                end
                panel.prof.highColorFrame:SetColor(high_color.r, high_color.g, high_color.b, high_color.a)
            end
            if panel.prof.displayFishing and prof ~= nil and prof.current_profession == addonTable.Constants.FISHING then
                panel.prof.displayFishing:SetValue(prof.display or true)
            end
        end
    end, geterrorhandler())
end

local category, layout = Settings.RegisterCanvasLayoutSubcategory(addonTable.OptionDialog.ABOUT.category, panel.frame, L.GENERAL)
addonTable.OptionDialog.GENERAL.category = category
addonTable.OptionDialog.GENERAL.layout = layout