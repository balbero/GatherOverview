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
        self.showInInstance = AceGUI:Create("CheckBox")
        self.showInInstance.message = {
            name = addonTable.Locales.SHOW_IN_INSTANCES,
            description = addonTable.Locales.SHOW_IN_INSTANCES_SUB
        }
        self.showInInstance:SetFullWidth(true)
        self.showInInstance:SetLabel(addonTable.Locales.SHOW_IN_INSTANCES)
        self.showInInstance:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_IN_INSTANCES))
        self.showInInstance:SetCallback("OnValueChanged", function(_, _, value)
            addonTable.Config.Set(addonTable.Config.Options.SHOW_IN_INSTANCES, value)
        end)
        self.showInInstance:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
        self.showInInstance:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
        optionsInset:AddChild(self.showInInstance)

        self.showTotal = AceGUI:Create("CheckBox")
        self.showTotal.message = {
            name = addonTable.Locales.SHOW_TOTAL,
            description = addonTable.Locales.SHOW_TOTAL_SUB
        }
        self.showTotal:SetFullWidth(true)
        self.showTotal:SetLabel(addonTable.Locales.SHOW_TOTAL)
        self.showTotal:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOTAL))
        self.showTotal:SetCallback("OnValueChanged", function(_, _, value)
            addonTable.Config.Set(addonTable.Config.Options.SHOW_TOTAL, value)
        end)
        self.showTotal:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
        self.showTotal:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
        optionsInset:AddChild(self.showTotal)

        self.displayInRestZone = AceGUI:Create("CheckBox")
        self.displayInRestZone.message = {
            name = addonTable.Locales.DISPLAY_IN_REPO_ZONE,
            description = addonTable.Locales.DISPLAY_IN_REPO_ZONE_SUB
        }
        self.displayInRestZone:SetFullWidth(true)
        self.displayInRestZone:SetLabel(addonTable.Locales.DISPLAY_IN_REPO_ZONE)
        self.displayInRestZone:SetValue(addonTable.Config.Get(addonTable.Config.Options.DISPLAY_IN_REPO_ZONE))
        self.displayInRestZone:SetCallback("OnValueChanged", function(_, _, value)
            addonTable.Config.Set(addonTable.Config.Options.DISPLAY_IN_REPO_ZONE, value)
        end)
        self.displayInRestZone:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
        self.displayInRestZone:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
        optionsInset:AddChild(self.displayInRestZone)
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

    local iconPerRowGroup = AceGUI:Create("SimpleGroup")
    iconPerRowGroup:SetFullWidth(true)
    iconPerRowGroup:SetLayout("Flow")
    self.iconPerRowSlider = AceGUI:Create("Slider")
    self.iconPerRowSlider:SetWidth(150)
    self.iconPerRowSlider:SetSliderValues(2, 12, 1)
    self.iconPerRowSlider:SetLabel(addonTable.Locales.ROW_AMOUNT)
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

        if prof.name == addonTable.Locales.FISHING then
            self.displayFishing = AceGUI:Create("CheckBox")
            self.displayFishing.message = {
                name = addonTable.Locales.DISPLAY_FISHING,
                description = addonTable.Locales.DISPLAY_FISHING_SUB
            }
            self.displayFishing:SetFullWidth(true)
            self.displayFishing:SetLabel(addonTable.Locales.DISPLAY_FISHING)
            self.displayFishing:SetValue(prof.display)
            self.displayFishing:SetCallback("OnValueChanged", function(_, _, value)
                if not prof then prof = {} end
                prof.display = value
                addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
                addonTable.MainFrame.UpdateUI()
            end)
            self.displayFishing:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
            self.displayFishing:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
            profContainer:AddChild(self.displayFishing)
        end
        local iconSizeGroup = AceGUI:Create("SimpleGroup")
        iconSizeGroup:SetFullWidth(true)
        iconSizeGroup:SetLayout("Flow")
        local iconSizeLabel = AceGUI:Create("Label")
        iconSizeLabel:SetText(addonTable.Locales.ICON_SIZE)
        iconSizeGroup:AddChild(iconSizeLabel)
        self.prof.iconWidthSlider = AceGUI:Create("Slider")
        self.prof.iconWidthSlider:SetWidth(150)
        self.prof.iconWidthSlider:SetSliderValues(16, 64, 1)
        self.prof.iconWidthSlider:SetLabel(addonTable.Locales.WIDTH)
        self.prof.iconWidthSlider:SetValue(prof.icon_width or addonTable.Config.Get(addonTable.Config.Options.ICON_WIDTH))
        self.prof.iconWidthSlider:SetCallback("OnMouseUp", function(_,_, value)
            if not prof then prof = {} end
            prof.icon_width = value
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        iconSizeGroup:AddChild(self.prof.iconWidthSlider)
        self.prof.iconHeightSlider = AceGUI:Create("Slider")
        self.prof.iconHeightSlider:SetWidth(150)
        self.prof.iconHeightSlider:SetSliderValues(16, 64, 1)
        self.prof.iconHeightSlider:SetLabel(addonTable.Locales.HEIGHT)
        self.prof.iconHeightSlider:SetValue(prof.icon_height or addonTable.Config.Get(addonTable.Config.Options.ICON_HEIGHT))
        self.prof.iconHeightSlider:SetCallback("OnMouseUp", function(_,_, value)
            if not prof then prof = {} end
            prof.icon_height = value
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        iconSizeGroup:AddChild(self.prof.iconHeightSlider)
        profContainer:AddChild(iconSizeGroup)
        
        -- Low Threshold input for this profession
        local profLowContainer = addonTable.Components.GetLowThresholdAndColorPickerGroup(self, prof)
        profContainer:AddChild(profLowContainer)

        -- Median Threshold Color for this profession
        local profMedContainer = AceGUI:Create("SimpleGroup")
        profMedContainer:SetFullWidth(true)
        profMedContainer:SetLayout("Flow")

        profMedContainer:AddChild(addonTable.Components.GetHSpace(177)) -- space before threshold label + threshold label width + edit box width + space after editbox
        
        self.prof.medColorFrame = AceGUI:Create("ColorPicker")
        local med_color = prof.medium_color or addonTable.Config.Get(addonTable.Config.Options.MEDIUM_THRESHOLD_COLOR)
        self.prof.medColorFrame:SetLabel(addonTable.Locales.MEDIUM_COLOR)
        self.prof.medColorFrame:SetColor(med_color.r, med_color.g, med_color.b, med_color.a)
        self.prof.medColorFrame:SetCallback("OnValueChanged",  function(_, _, newr, newg, newb, newa)
            if not prof then prof = {} end
            if prof.medium_color ~= nil and prof.medium_color == {r = newr, g = newg, b = newb, a = newa} then return end
            prof.medium_color = {r = newr, g = newg, b = newb, a = newa}
            addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
            addonTable.MainFrame.UpdateUI()
        end)
        profMedContainer:AddChild(self.prof.medColorFrame)
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
        panel.showInInstance:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_IN_INSTANCES))
        panel.showTotal:SetValue(addonTable.Config.Get(addonTable.Config.Options.SHOW_TOTAL))
        panel.displayInRestZone:SetValue(addonTable.Config.Get(addonTable.Config.Options.DISPLAY_IN_REPO_ZONE))
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
            if panel.prof.displayFishing and prof ~= nil and prof.name == addonTable.Locales.FISHING then
                panel.prof.displayFishing:SetValue(prof.display or true)
            end
        end
    end, geterrorhandler())
end

local category, layout = Settings.RegisterCanvasLayoutSubcategory(addonTable.OptionDialog.ABOUT.category, panel.frame, addonTable.Locales.GENERAL)
addonTable.OptionDialog.GENERAL.category = category
addonTable.OptionDialog.GENERAL.layout = layout