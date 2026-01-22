---@class addonTableGatherOverview
local addonTable = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")

local panel = AceGUI:Create("BlizOptionsGroup")
panel:SetTitle(addonTable.Locales.GENERAL)

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

addonTable.OptionDialog.GENERAL = panel

function panel:GetOptionInsetPanel()
    local optionsInset = AceGUI:Create("InlineGroup")
    optionsInset:SetTitle(addonTable.Locales.OPTION_DISPLAY)
    optionsInset:SetFullWidth(true)
    do
        self.showMinimapButton = AceGUI:Create("CheckBox")
        self.showMinimapButton:SetFullWidth(true)
        self.showMinimapButton:SetLabel(addonTable.Locales.SHOW_MAP_BUTTON)
        self.showMinimapButton:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_BUTTON))
        self.showMinimapButton:SetCallback("OnValueChanged", function(_, _, value)
            addonTable.Config.Set(addonTable.Config.Options.SHOW_BUTTON, value)
        end)
        optionsInset:AddChild(self.showMinimapButton)

        self.showInInstance = AceGUI:Create("CheckBox")
        self.showInInstance:SetFullWidth(true)
        self.showInInstance:SetLabel(addonTable.Locales.SHOW_IN_INSTANCES)
        self.showInInstance:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_IN_INSTANCES))
        self.showInInstance:SetCallback("OnValueChanged", function(_, _, value)
            addonTable.Config.Set(addonTable.Config.Options.SHOW_IN_INSTANCES, value)
        end)
        optionsInset:AddChild(self.showInInstance)
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
    professionsInset:SetTitle(addonTable.Locales.PROFESSIONS)
    professionsInset:SetFullWidth(true)
    for _, prof in pairs(professionsConfig) do
	    self.prof = {}
        local profContainer = AceGUI:Create("SimpleGroup")
        profContainer:SetFullWidth(true)
        profContainer:SetLayout("List")

        local profLabel = AceGUI:Create("Label")
        profLabel:SetColor(0.98, 0.82, 0, 1)
        profLabel:SetText(prof.name)
        profLabel:SetFullWidth(true)
        profContainer:AddChild(profLabel)

        local iconSizeGroup = AceGUI:Create("SimpleGroup")
        iconSizeGroup:SetFullWidth(true)
        iconSizeGroup:SetLayout("Flow")
        local iconSizeLabel = AceGUI:Create("Label")
        iconSizeLabel:SetText(addonTable.Locales.ICON_SIZE)
        iconSizeGroup:AddChild(iconSizeLabel)
        local iconWidthSlider = AceGUI:Create("Slider")
        iconWidthSlider:SetWidth(100)
        iconWidthSlider:SetSliderValues(16, 64, 1)
        iconWidthSlider:SetLabel(addonTable.Locales.WIDTH)
        iconWidthSlider:SetValue(prof.icon_width or addonTable.Config.Get(addonTable.Config.Options.ICON_WIDTH))
        iconWidthSlider:SetCallback("OnMouseUp", function(_,_, value)
            if not prof then prof = {} end
            prof.icon_width = value 
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        iconSizeGroup:AddChild(iconWidthSlider)
        local iconHeightSlider = AceGUI:Create("Slider")
        iconHeightSlider:SetWidth(100)
        iconHeightSlider:SetSliderValues(16, 64, 1)
        iconHeightSlider:SetLabel(addonTable.Locales.HEIGHT)
        iconHeightSlider:SetValue(prof.icon_height or addonTable.Config.Get(addonTable.Config.Options.ICON_HEIGHT))
        iconWidthSlider:SetCallback("OnMouseUp", function(_,_, value)
            if not prof then prof = {} end
            prof.icon_height = value 
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        iconSizeGroup:AddChild(iconHeightSlider)
        profContainer:AddChild(iconSizeGroup)
        
        -- Low Threshold input for this profession
        local profLowContainer = addonTable.Components.GetLowThresholdAndColorPickerGroup(self, prof)
        profContainer:AddChild(profLowContainer)

        -- Median Threshold Color for this profession
        local profMedContainer = AceGUI:Create("SimpleGroup")
        profMedContainer:SetFullWidth(true)
        profMedContainer:SetLayout("Flow")

        profMedContainer:AddChild(addonTable.Components.GetHSpace(177)) -- space before threshold label + threshold label width + edit box width + space after editbox
        
        local medColorFrame = AceGUI:Create("ColorPicker")
        local med_color = prof.medium_color or addonTable.Config.Get(addonTable.Config.Options.MEDIUM_THRESHOLD_COLOR)
        medColorFrame:SetLabel(addonTable.Locales.MEDIUM_COLOR)
        medColorFrame:SetColor(med_color.r, med_color.g, med_color.b, med_color.a)
        medColorFrame:SetCallback("OnValueChanged",  function(_, _, newr, newg, newb, newa)
            if not prof then prof = {} end
            if prof.medium_color ~= nil and prof.medium_color == {r = newr, g = newg, b = newb, a = newa} then return end
            prof.medium_color = {r = newr, g = newg, b = newb, a = newa}
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        profMedContainer:AddChild(medColorFrame)
        profContainer:AddChild(profMedContainer)

        -- High Threshold input for this profession
        local profHighContainer = addonTable.Components.GetHighThresholdAndColorPickerGroup(self, prof)
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
        panel.showMinimapButton:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_BUTTON))
        panel.showInInstance:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_IN_INSTANCES))
        for _, prof in ipairs(professionsConfig) do
            if panel.prof.lowThresholdInput then
                panel.prof.lowThresholdInput:SetText(tostring(prof and prof.low or 50))
            end
            if panel.prof.highThresholdInput then
                panel.prof.highThresholdInput:SetText(tostring(prof and prof.high or 100))
            end
            if panel.prof.lowColorButton then
                local lowColor = addonTable.Config.Get(addonTable.Config.Options.LOW_THRESHOLD_COLOR)
                if prof then
                    lowColor = prof.low_color or lowColor
                end
                panel.prof.lowColorButton.Texture:SetVertexColor(lowColor.r, lowColor.g, lowColor.b, lowColor.a)
            end
            if panel.prof.highColorButton then
                local high_color = addonTable.Config.Get(addonTable.Config.Options.HIGH_THRESHOLD_COLOR)
                if prof then
                    high_color = prof.high_color or high_color
                end
                panel.prof.highColorButton.Texture:SetVertexColor(high_color.r, high_color.g, high_color.b, high_color.a)
            end
        end
    end, geterrorhandler())
end

local category, layout = Settings.RegisterCanvasLayoutSubcategory(addonTable.OptionDialog.ABOUT.category, panel.frame, addonTable.Locales.GENERAL)
addonTable.OptionDialog.GENERAL.category = category
addonTable.OptionDialog.GENERAL.layout = layout