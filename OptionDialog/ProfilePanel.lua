---@class addonTableGatherOverview
local addonTable = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")

local panel = AceGUI:Create("BlizOptionsGroup")
panel:SetTitle(addonTable.Locales.PROFILES)

panel:SetCallback("OnCommit", function()
    --panel.okay()
end)
panel:SetCallback("OnRefresh", function()
    --panel.refresh()
end)
panel:SetCallback("OnShow", function()
    if not panel.initialized then
        panel:Setup()
    end
end)

addonTable.OptionDialog.PROFILES = panel


function panel:Setup()
    panel.initialized = true
    local VGroup = AceGUI:Create("SimpleGroup")
    VGroup:SetFullWidth(true)
    VGroup:SetLayout("List")

    local description = AceGUI:Create("Label")
    description:SetText(addonTable.Locales.PROFILES_DESCRIPTION)
    description:SetFullWidth(true)
    VGroup:AddChild(description)
    local resetDescription = AceGUI:Create("Label")
    resetDescription:SetText(addonTable.Locales.RESET_PROFILE_DESCRIPTION)
    resetDescription:SetFullWidth(true)
    VGroup:AddChild(resetDescription)

    local resetGroup = AceGUI:Create("SimpleGroup")
    resetGroup:SetFullWidth(true)
    resetGroup:SetLayout("Flow")
    local profileReset = AceGUI:Create("Button")
    profileReset:SetText(addonTable.Locales.RESET)
    profileReset:SetCallback("OnClick", function()
        addonTable.Config.ResetProfile()
        addonTable.Core.MigrateSettings()
    end)
    resetGroup:AddChild(profileReset)
    resetGroup:AddChild(addonTable.Components.GetHSpace(10))
    local curentProfileLabel = AceGUI:Create("Label")
    curentProfileLabel:SetText(addonTable.Locales.CURRENT_PROFILE)
    curentProfileLabel:SetWidth(100)
    resetGroup:AddChild(curentProfileLabel)

    local curentProfileName = AceGUI:Create("Label")
    curentProfileName:SetColor(0.98, 0.82, 0, 1)
    curentProfileName:SetText(GATHEROVERVIEW_CURRENT_PROFILE)
    curentProfileName:SetWidth(150)
    resetGroup:AddChild(curentProfileName)
    VGroup:AddChild(resetGroup)

    VGroup:AddChild(addonTable.Components.GetVSpace(10))

    local newProfileDesc = AceGUI:Create("Label")
    newProfileDesc:SetText(addonTable.Locales.CREATE_NEW_EMPTY_PROFILE)
    newProfileDesc:SetFullWidth(true)
    VGroup:AddChild(newProfileDesc)

    local copyGroup = AceGUI:Create("SimpleGroup")
    copyGroup:SetFullWidth(true)
    copyGroup:SetLayout("Flow")
    local newProfileInput = AceGUI:Create("EditBox")
    newProfileInput:SetLabel(addonTable.Locales.NEW_PROFILE)
    newProfileInput:SetCallback("OnEnterPressed", function(_, _, text)
        if text and text ~= "" then
            addonTable.Config.MakeProfile(text, false)
            newProfileInput:SetText("")
        end
    end)
    copyGroup:AddChild(newProfileInput)
    copyGroup:AddChild(addonTable.Components.GetHSpace(10))
    local existingProfilSelector = AceGUI:Create("Dropdown")
    existingProfilSelector:SetLabel(addonTable.Locales.EXISTING_PROFILE)
    existingProfilSelector:SetList(addonTable.Config.GetProfileNames())
    copyGroup:AddChild(existingProfilSelector)
    VGroup:AddChild(copyGroup)

    VGroup:AddChild(addonTable.Components.GetVSpace(10))

    local copyProfileLabel = AceGUI:Create("Label")
    copyProfileLabel:SetText(addonTable.Locales.CREATE_NEW_PROFILE_BY_CLONING_EXISTING_ONE)
    copyProfileLabel:SetFullWidth(true)
    VGroup:AddChild(copyProfileLabel)
    local copyProfileFrom = AceGUI:Create("Dropdown")
    copyProfileFrom:SetLabel(addonTable.Locales.COPY_EXISTING_PROFILE)
    copyProfileFrom:SetList(addonTable.Config.GetProfileNames())
    copyProfileFrom:SetCallback("OnValueChanged", function(_, _, profil)
        if profil and profil ~= "" then
            self.toCopy = profil
            addonTable.Components.ShowConfirmationDialog(
                addonTable.Locales.CONFIRM_PROFILE_COPY_TITLE,
                addonTable.Locales.CONFIRM_PROFILE_COPY_TEXT:format(profil),
                function()
                    addonTable.Config.MakeProfile(profil, true)
                    copyProfileFrom:SetValue("")
                    self.toCopy = nil
                end,
                function()
                    copyProfileFrom:SetValue("")
                    self.toCopy = nil
                end
            )
        end
    end)
    VGroup:AddChild(copyProfileFrom)
    
    VGroup:AddChild(addonTable.Components.GetVSpace(10))
    local removeProfileLabel = AceGUI:Create("Label")
    removeProfileLabel:SetText(addonTable.Locales.REMOVE_EXISTING_PROFILE)
    removeProfileLabel:SetFullWidth(true)
    VGroup:AddChild(removeProfileLabel)
    local removeProfileSelector = AceGUI:Create("Dropdown")
    removeProfileSelector:SetLabel(addonTable.Locales.REMOVE_PROFILE)
    removeProfileSelector:SetList(addonTable.Config.GetProfileNames(true))
    removeProfileSelector:SetCallback("OnValueChanged", function(_, _, profil)
        if profil and profil ~= "" then
            self.toDelete = profil
            addonTable.Components.ShowConfirmationDialog(
                addonTable.Locales.CONFIRM_PROFILE_DELETION_TITLE,
                addonTable.Locales.CONFIRM_PROFILE_DELETION_TEXT:format(profil),
                function()
                    addonTable.Config.DeleteProfile(self.toDelete)
                    removeProfileSelector:SetValue("")
                    self.toDelete = nil
                end,
                function()
                    removeProfileSelector:SetValue("")
                    self.toDelete = nil
                end
            )
        end
    end)
    VGroup:AddChild(removeProfileSelector)

    self:AddChild(VGroup)
end


local category, layout = Settings.RegisterCanvasLayoutSubcategory(addonTable.OptionDialog.ABOUT.category, panel.frame, addonTable.Locales.PROFILES)
addonTable.OptionDialog.PROFILES.category = category
addonTable.OptionDialog.PROFILES.layout = layout