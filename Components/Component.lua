---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Components = {}

function addonTable.Components.GetHSpace(width)
	local AceGUI = LibStub("AceGUI-3.0")
	local space = AceGUI:Create("Label")
	space:SetText(" ") -- require even for width-only spacer
	space:SetWidth(width)
	return space
end

function addonTable.Components.GetVSpace(height)
	local AceGUI = LibStub("AceGUI-3.0")
	local space = AceGUI:Create("Label")
	space:SetText(" ") -- require even for height-only spacer
	space:SetHeight(height)
	space:SetFullWidth(true)
	return space
end

function addonTable.Components.CreateConfirmationPopup(title, text, onOk, onCancel)
	local AceGUI = LibStub("AceGUI-3.0")
    -- Créer le frame principal (popup)
    local frame = AceGUI:Create("Frame")
    frame:SetTitle(title)
    frame:SetWidth(300)
    frame:SetHeight(150)
    frame:SetLayout("Flow")  -- Layout vertical pour empiler les éléments

    -- Ajouter le label avec le texte personnalisé
    local label = AceGUI:Create("Label")
    label:SetText(text)
    label:SetFullWidth(true)
    frame:AddChild(label)

    -- Créer un conteneur pour les boutons (pour les aligner horizontalement)
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)

    -- Bouton "Cancel"
    local cancelButton = AceGUI:Create("Button")
    cancelButton:SetText("Cancel")
    cancelButton:SetWidth(100)
    cancelButton:SetCallback("OnClick", function()
        if onCancel then
            onCancel()
        end
        frame:Hide()  -- Fermer la popup
    end)
    buttonGroup:AddChild(cancelButton)

    -- Bouton "Ok"
    local okButton = AceGUI:Create("Button")
    okButton:SetText("Ok")
    okButton:SetWidth(100)
    okButton:SetCallback("OnClick", function()
        if onOk then
            onOk()
        end
        frame:Hide()  -- Fermer la popup après action
    end)
    buttonGroup:AddChild(okButton)

    -- Ajouter le groupe de boutons au frame
    frame:AddChild(buttonGroup)

    -- Afficher la popup
    frame:Show()
end


function addonTable.Components.GetHighThresholdAndColorPickerGroup(parent, prof)
    local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
	local AceGUI = LibStub("AceGUI-3.0")
	local profHighContainer = AceGUI:Create("SimpleGroup")
	profHighContainer:SetFullWidth(true)
	profHighContainer:SetLayout("Flow")
	profHighContainer:AddChild(addonTable.Components.GetHSpace(10))
	local highThresholdLabel = AceGUI:Create("Label")
	highThresholdLabel:SetText(addonTable.Locales.HIGH_THRESHOLD .. ":")
	highThresholdLabel:SetWidth(80)
	profHighContainer:AddChild(highThresholdLabel)

	parent.prof.highThresholdInput = AceGUI:Create("EditBox")
	parent.prof.highThresholdInput:SetWidth(77)
	parent.prof.highThresholdInput:SetText(tostring(prof and prof.high or 100))
	parent.prof.highThresholdInput:SetMaxLetters(3)
	parent.prof.highThresholdInput:SetCallback("OnEnterPressed", function(_, _, text)
		local value = tonumber(text)
		if value then
			if not prof then prof = {} end
			prof.high = value
			addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
			addonTable.MainFrame.UpdateUI()
		end
	end)
	profHighContainer:AddChild(parent.prof.highThresholdInput)

	profHighContainer:AddChild(addonTable.Components.GetHSpace(10))

	local highColorFrame = AceGUI:Create("ColorPicker")
	local high_color = prof.high_color or addonTable.Config.Get(addonTable.Config.Options.HIGH_THRESHOLD_COLOR)
	highColorFrame:SetColor(high_color.r, high_color.g, high_color.b, high_color.a)
	highColorFrame:SetCallback("OnValueChanged", function(_, _, newr, newg, newb, newa)
		if not prof then prof = {} end
		prof.high_color = {r = newr, g = newg, b = newb, a = newa}
		addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
		addonTable.MainFrame.UpdateUI()
	end)
	profHighContainer:AddChild(highColorFrame)
	return profHighContainer
end

function addonTable.Components.GetLowThresholdAndColorPickerGroup(parent, prof)
    local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
	local AceGUI = LibStub("AceGUI-3.0")
	local profLowContainer = AceGUI:Create("SimpleGroup")
	profLowContainer:SetFullWidth(true)
	profLowContainer:SetLayout("Flow")

	-- Low Threshold input for this profession
	profLowContainer:AddChild(addonTable.Components.GetHSpace(10))
	
	local lowThresholdLabel = AceGUI:Create("Label")
	lowThresholdLabel:SetText(addonTable.Locales.LOW_THRESHOLD .. ":")
	lowThresholdLabel:SetWidth(80)
	profLowContainer:AddChild(lowThresholdLabel)

	parent.prof.lowThresholdInput = AceGUI:Create("EditBox")
	parent.prof.lowThresholdInput:SetWidth(77)
	parent.prof.lowThresholdInput:SetText(tostring(prof and prof.low or 50))
	parent.prof.lowThresholdInput:SetMaxLetters(3)
	parent.prof.lowThresholdInput:SetCallback("OnEnterPressed", function(_, _, text)
		local value = tonumber(text)
		if value then
			if not prof then prof = {} end
			prof.low = value
			addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
			addonTable.MainFrame.UpdateUI()
		end
	end)
	profLowContainer:AddChild(parent.prof.lowThresholdInput)

	profLowContainer:AddChild(addonTable.Components.GetHSpace(10))

	local lowColorFrame = AceGUI:Create("ColorPicker")
	local low_color = prof.low_color or addonTable.Config.Get(addonTable.Config.Options.LOW_THRESHOLD_COLOR)
	lowColorFrame:SetColor(low_color.r, low_color.g, low_color.b, low_color.a)
	lowColorFrame:SetCallback("OnValueChanged", function(_, _, newr, newg, newb, newa)
		if not prof then prof = {} end
		prof.low_color = {r = newr, g = newg, b = newb, a = newa}
		addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
		addonTable.MainFrame.UpdateUI()
	end)
	
	profLowContainer:AddChild(lowColorFrame)
	return profLowContainer
end
