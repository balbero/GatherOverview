---@class addonTablePlatynator
local addonTable = select(2, ...)
local InCombatLockdown = InCombatLockdown

addonTable.Components = {}


local tooltip = tooltip or CreateFrame("GameTooltip", "GatherOverviewTooltip", UIParent, "GameTooltipTemplate")


--- Create a tooltip for the widget
---@param widget AceGUI-3.0 widget concerned by the tooltip
---@param event string event to be catched
function addonTable.Components.OptionOnMouseOver(widget, event)
	--show a tooltip/set the status bar to the desc text
	local user = widget.message
	local name = user.name
	local desc = user.description
	local usage = user.usage

	tooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
	tooltip:AddLine(name, 1, .82, 0, true)

	if type(desc) == "string" then
		tooltip:AddLine(desc, 1, 1, 1, true)
	end
	if type(usage) == "string" then
		tooltip:AddLine("Usage: "..usage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
	end

	tooltip:Show()
end

function addonTable.Components.OptionOnMouseLeave(widget, event)
	tooltip:Hide()
end

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

local function createPopup()
	local frame = addonTable.Components.popupFrame
	if not frame then
		frame = CreateFrame("Frame", nil, UIParent)
		frame:Hide()
		addonTable.Components.popupFrame = frame
		frame:SetPoint("CENTER", UIParent, "CENTER")
		frame:SetSize(320, 72)
		frame:EnableMouse(true) -- Do not allow click-through on the frame
		frame:SetFrameStrata("TOOLTIP")
		frame:SetFrameLevel(100) -- Lots of room to draw under it
		frame:SetScript("OnKeyDown", function(self, key)
			if key == "ESCAPE" then
				if not InCombatLockdown() then
					self:SetPropagateKeyboardInput(false)
				end
				if self.cancel:IsShown() then
					self.cancel:Click()
				else -- Showing a validation error
					self:Hide()
				end
			elseif not InCombatLockdown() then
				self:SetPropagateKeyboardInput(true)
			end
		end)

		local border = CreateFrame("Frame", nil, frame, "DialogBorderOpaqueTemplate")
		border:SetAllPoints(frame)
		frame:SetFixedFrameStrata(true)
		frame:SetFixedFrameLevel(true)

		local text = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		text:SetSize(290, 0)
		text:SetPoint("TOP", 0, -16)
		frame.text = text

		local function newButton(newText)
			local button = CreateFrame("Button", nil, frame)
			button:SetSize(128, 21)
			button:SetNormalFontObject(GameFontNormal)
			button:SetHighlightFontObject(GameFontHighlight)
			button:SetNormalTexture(130763) -- "Interface\\Buttons\\UI-DialogBox-Button-Up"
			button:GetNormalTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
			button:SetPushedTexture(130761) -- "Interface\\Buttons\\UI-DialogBox-Button-Down"
			button:GetPushedTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
			button:SetHighlightTexture(130762) -- "Interface\\Buttons\\UI-DialogBox-Button-Highlight"
			button:GetHighlightTexture():SetTexCoord(0.0, 1.0, 0.0, 0.71875)
			button:SetText(newText)
			return button
		end

		local accept = newButton(ACCEPT)
		accept:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -6, 16)
		frame.accept = accept

		local cancel = newButton(CANCEL)
		cancel:SetPoint("LEFT", accept, "RIGHT", 13, 0)
		frame.cancel = cancel
	end
	return frame
end

--- Show a confirmation popup
---@param text string the message display in the popup
---@param onOk function A function to be executed when user accept
---@param onCancel function A function to be executed when user cancel
function addonTable.Components.ShowConfirmationDialog(text, onOk, onCancel)
    -- Créer le frame principal (popup)
    local frame = addonTable.Components.popupFrame
	if not frame then
		frame = createPopup()
	end
	frame:Show()
	frame.text:SetText(text)
	local height = 61 + frame.text:GetHeight()
	frame:SetHeight(height)
	
    frame.cancel:SetScript("OnClick", function(self)
        if onCancel then
            onCancel()
        end
        frame:Hide()  -- Fermer la popup
		self:SetScript("OnClick", nil)
		frame.cancel:SetScript("OnClick", nil)
    end)

    -- Bouton "Ok"
    frame.accept:SetScript("OnClick", function(self)
        if onOk then
            onOk()
        end
        frame:Hide()  -- Fermer la popup après action
		self:SetScript("OnClick", nil)
		frame.cancel:SetScript("OnClick", nil)
    end)

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

	parent.prof.highColorFrame = AceGUI:Create("ColorPicker")
	local high_color = prof.high_color or addonTable.Config.Get(addonTable.Config.Options.HIGH_THRESHOLD_COLOR)
	parent.prof.highColorFrame:SetColor(high_color.r, high_color.g, high_color.b, high_color.a)
	parent.prof.highColorFrame:SetCallback("OnValueChanged", function(_, _, newr, newg, newb, newa)
		if not prof then prof = {} end
		prof.high_color = {r = newr, g = newg, b = newb, a = newa}
		addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
		addonTable.MainFrame.UpdateUI()
	end)
	profHighContainer:AddChild(parent.prof.highColorFrame)
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

	parent.prof.lowColorFrame = AceGUI:Create("ColorPicker")
	local low_color = prof.low_color or addonTable.Config.Get(addonTable.Config.Options.LOW_THRESHOLD_COLOR)
	parent.prof.lowColorFrame:SetColor(low_color.r, low_color.g, low_color.b, low_color.a)
	parent.prof.lowColorFrame:SetCallback("OnValueChanged", function(_, _, newr, newg, newb, newa)
		if not prof then prof = {} end
		prof.low_color = {r = newr, g = newg, b = newb, a = newa}
		addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, professionsConfig)
		addonTable.MainFrame.UpdateUI()
	end)
	
	profLowContainer:AddChild(parent.prof.lowColorFrame)
	return profLowContainer
end
