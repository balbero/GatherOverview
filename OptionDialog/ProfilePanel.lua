---@class addonTableGatherOverview
local addonTable = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")

local panel = AceGUI:Create("BlizOptionsGroup")
panel:SetTitle(addonTable.Locales.PROFILES)

panel:SetCallback("refresh", function()
    panel.refresh()
    addonTable.MainFrame.UpdateUI()
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
    end)
    resetGroup:AddChild(profileReset)
    resetGroup:AddChild(addonTable.Components.GetHSpace(10))
    local curentProfileLabel = AceGUI:Create("Label")
    curentProfileLabel:SetText(addonTable.Locales.CURRENT_PROFILE)
    curentProfileLabel:SetWidth(100)
    resetGroup:AddChild(curentProfileLabel)

    self.curentProfileName = AceGUI:Create("Label")
    self.curentProfileName:SetColor(0.98, 0.82, 0, 1)
    self.curentProfileName:SetText(GATHEROVERVIEW_CURRENT_PROFILE)
    self.curentProfileName:SetWidth(150)
    resetGroup:AddChild(self.curentProfileName)
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
    newProfileInput.message = {
        name = addonTable.Locales.NEW_PROFILE,
        description = addonTable.Locales.NEW_PROFILE_SUB
    }
    newProfileInput:SetLabel(addonTable.Locales.NEW_PROFILE)
    newProfileInput:SetCallback("OnEnterPressed", function(_, _, text)
        if text and text ~= "" then
            addonTable.Config.MakeProfile(text, false)
            self.refresh()
            newProfileInput:SetText("")
        end
    end)
    newProfileInput:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
    newProfileInput:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
    copyGroup:AddChild(newProfileInput)
    copyGroup:AddChild(addonTable.Components.GetHSpace(10))

    
    
    self.existingProfilSelector = AceGUI:Create("Dropdown")
    self.existingProfilSelector.message = {
        name = addonTable.Locales.EXISTING_PROFILE,
        description = addonTable.Locales.EXISTING_PROFILE_SUB
    }
    self.existingProfilSelector:SetLabel(addonTable.Locales.EXISTING_PROFILE)
    self.existingProfilSelector:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
    self.existingProfilSelector:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
    self.existingProfilSelector:SetCallback("OnValueChanged", function(_, _, profil)
        if profil and profil ~= "" then
            local copyProfilesName = addonTable.Config.GetProfileNames()
            self.profilNb = profil
            local old = addonTable.Config.CurrentProfile
            local toCopy = copyProfilesName[profil]
            addonTable.Config.ChangeProfile(toCopy, old)
            self.refresh()
            self.existingProfilSelector:SetValue("")
            toCopy = nil
            self.profilNb = nil
        end
    end)
    copyGroup:AddChild(self.existingProfilSelector)
    VGroup:AddChild(copyGroup)

    VGroup:AddChild(addonTable.Components.GetVSpace(10))

    local copyProfileLabel = AceGUI:Create("Label")
    copyProfileLabel:SetText(addonTable.Locales.CREATE_NEW_PROFILE_BY_CLONING_EXISTING_ONE)
    copyProfileLabel:SetFullWidth(true)
    VGroup:AddChild(copyProfileLabel)

    self.copyProfileFrom = AceGUI:Create("Dropdown")
    self.copyProfileFrom:SetLabel(addonTable.Locales.COPY_EXISTING_PROFILE)
    self.copyProfileFrom:SetCallback("OnValueChanged", function(_, _, profil)
        if profil and profil ~= "" then
            local copyProfilesName = addonTable.Config.GetProfileNames()
            self.profilNb = profil
            local toCopy = copyProfilesName[profil]
            addonTable.Components.ShowConfirmationDialog(
                addonTable.Locales.CONFIRM_PROFILE_COPY_TEXT:format(toCopy),
                function()
                    addonTable.Config.MakeProfile(toCopy.."_copy", true)
                    self.refresh()
                    self.copyProfileFrom:SetValue("")
                    toCopy = nil
                    self.profilNb =  nil
                end,
                function()
                    self.copyProfileFrom:SetValue("")
                    toCopy = nil
                    self.profilNb =  nil
                end
            )
        end
    end)
    VGroup:AddChild(self.copyProfileFrom)
    
    VGroup:AddChild(addonTable.Components.GetVSpace(10))

    local removeProfileLabel = AceGUI:Create("Label")
    removeProfileLabel:SetText(addonTable.Locales.REMOVE_EXISTING_PROFILE)
    removeProfileLabel:SetFullWidth(true)
    VGroup:AddChild(removeProfileLabel)
    self.removeProfileSelector = AceGUI:Create("Dropdown")
    self.removeProfileSelector.message = {
        name = addonTable.Locales.REMOVE_PROFILE,
        description = addonTable.Locales.REMOVE_PROFILE_SUB
    }
    self.removeProfileSelector:SetLabel(addonTable.Locales.REMOVE_PROFILE)
    self.removeProfileSelector:SetCallback("OnValueChanged", function(_, _, profil)
        if profil and profil ~= "" then
            self.profilNb = profil
            local delProfilesName = addonTable.Config.GetProfileNames(true)
            local toDelete = delProfilesName[profil]
            addonTable.Components.ShowConfirmationDialog(
                addonTable.Locales.CONFIRM_PROFILE_DELETION_TEXT:format(toDelete),
                function()
                    addonTable.Config.DeleteProfile(toDelete)
                    self.refresh()
                    self.removeProfileSelector:SetValue("")
                    self.profilNb =  nil
                end,
                function()
                    self.removeProfileSelector:SetValue("")
                    self.profilNb =  nil
                end
            )
        end
    end)
    self.removeProfileSelector:SetCallback("OnEnter", addonTable.Components.OptionOnMouseOver)
    self.removeProfileSelector:SetCallback("OnLeave", addonTable.Components.OptionOnMouseLeave)
    VGroup:AddChild(self.removeProfileSelector)

    self:AddChild(VGroup)
end

function panel.refresh()
    xpcall(function()

        if not panel.initialized then
            panel:Setup()
        end

        panel.curentProfileName:SetText(GATHEROVERVIEW_CURRENT_PROFILE)

        local copyProfilesName = addonTable.Config.GetProfileNames()
        panel.existingProfilSelector:SetList(copyProfilesName)
        panel.copyProfileFrom:SetList(copyProfilesName)

        local delProfilesName = addonTable.Config.GetProfileNames(true)
        if next(delProfilesName) == nil then
            panel.removeProfileSelector:SetDisabled(true)
        else
            panel.removeProfileSelector:SetDisabled(false)
            panel.removeProfileSelector:SetList(delProfilesName)
        end
        
    end, geterrorhandler())
end

local category, layout = Settings.RegisterCanvasLayoutSubcategory(addonTable.OptionDialog.ABOUT.category, panel.frame, addonTable.Locales.PROFILES)
addonTable.OptionDialog.PROFILES.category = category
addonTable.OptionDialog.PROFILES.layout = layout