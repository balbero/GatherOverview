---@class addonTableGatherOverview
local addonTable = select(2, ...)
addonTable.MainFrame = {}
addonTable.MainFrame.Counts = {}

local L = addonTable.Locales

local function Nop(...)
end
GetItemReagentQualityInfo = C_TradeSkillUI and C_TradeSkillUI.GetItemReagentQualityInfo or Nop

local MIN_W, MIN_H = 150, 50
local MAX_WINDOWS = 5 -- on for each profession and a last for the gathered reagent
local IMAGES = "Interface\\AddOns\\GatherOverview\\Assets\\Images\\"
local FONTS = "Interface\\AddOns\\GatherOverview\\Assets\\Fonts\\"
local _windows = {}
addonTable._windows = _windows

local headerHeight = 20
local iconSpacingX = 10

local function GetMissingCurrencyFromQuest(item)
    local ret = tLength(item.questId)
    for _,id in ipairs(item.questId) do
        if C_QuestLog.IsQuestFlaggedCompleted(id) then
            ret = ret - 1
        end
    end
    return ret
end

local function GetCatchUpCurrencyLeft(id)
  local info = C_CurrencyInfo.GetCurrencyInfo(id)
  return {
        quantity = info.quantity,
        max = info.maxQuantity,
        weeklyEarned = info.quantityEarnedThisWeek,
        maxWeeklyEarned = info.maxWeeklyQuantity,
        totalEarned = info.totalEarned,
    }
end

local function GetSortedProfessions()
    local professionSetting = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    -- Get player's learned professions
    local prof1, prof2, _, fishing = GetProfessions()
    local learnedProfessions = {}
    if prof1 then
        local name = GetProfessionInfo(prof1)
        learnedProfessions[name] = true
    end
    if prof2 then
        local name = GetProfessionInfo(prof2)
        learnedProfessions[name] = true
    end
    if fishing then
        local name = GetProfessionInfo(fishing)
        learnedProfessions[name] = true
    end

    learnedProfessions[addonTable.Locales.OTHER_STUFF] = true

    -- Collect enabled and learned categories
    local enabledCategories = {}
    for category, _ in pairs(addonTable.MainFrame.Counts) do
        local professionTranslation = addonTable.ProfessionTranslate[category]
        local display = false
        for _, prof in pairs(professionSetting) do
            if professionTranslation == addonTable.Config.GetProfessionNameFromIndex(prof.current_profession) then
                display = prof.enabled
                break
            end
        end
        if display and learnedProfessions[professionTranslation] then
            table.insert(enabledCategories, category)
        end
    end

    -- Sort enabled categories: prioritize Mining, Herbalism, Skinning, then Fishing
    table.sort(enabledCategories, function(a, b)
        local order = {MINING = 1, HERBALISM = 2, SKINNING = 3, FISHING = 4, OTHER_STUFF = 5}
        return order[a] < order[b]
    end)
    return enabledCategories
end

local function CreateIcon(parent, itemId)
    local button = CreateFrame("Frame", nil, parent)
    -- button:SetSize(iconW, iconH)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(C_Item.GetItemIconByID(itemId))
    local info = GetItemReagentQualityInfo(itemId)

    if info and info.icon then
        local qualityText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        qualityText:SetPoint("TOPLEFT", button, "TOPLEFT", -7, 7)
        local text = "|A:"..info.icon..":20:20|a"
        qualityText:SetText(text)
    end

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOP", button, "BOTTOM", 0, -5)

    button.icon = icon
    button.text = text

    return button
end

local function UpdateToolTip(button, itemId, message)
    button:SetScript("OnEnter", function(self)
        if message then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(C_Item.GetItemInfo(itemId), 1, .82, 0, true)
            GameTooltip:AddLine(message, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function(self)
        if message then
            GameTooltip:Hide()
        end
    end)
end 

local function GetCountValue(displayCount)
    local ret = displayCount
    if displayCount > 999 then
        ret = math.floor(displayCount / 1000) .. "K+"
    end
    return ret
end

local function GetFont()
    return FONTS.."Expressway.TTF"
end


--------------------------------------------------
--- For db
--------------------------------------------------

local function GetWindowConfig(category)
    local cfg = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    return cfg[category]
end

local function SaveWindowPosition(category, frame)
    local cfg = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)

    local left, top = frame:GetLeft(), frame:GetTop()
    if left and top then
        cfg[category].position = { x = left, y = top }
        addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, cfg)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
    end
end

local function SaveWindowConfig(category, wCfg)
    local cfg = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    cfg[category] = wCfg
    addonTable.Config.Set(addonTable.Config.Options.PROFESSIONS, cfg)
    return cfg
end

--------------------------------------------------s

local _contextMenu, _contextMenuSub
local _contextMenuAnchor = nil  -- tracks which button opened the menu (for toggle)
local CTX_ARROW_ICON = "Interface\\AddOns\\GatherOverview\\Assets\\arrow.png"

local function MakeMenuPanel(level)
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(200 + (level or 0) * 10)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.067, 0.067, 0.067, 0.95)
    f._pool = {}
    f:Hide()
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:SetScript("OnEvent", function(self) self:Hide() end)
    return f
end

local function EnsureMenuRow(menu, idx)
    local row = menu._pool[idx]
    if row then return row end
    local fontPath = GetFont()
    row = CreateFrame("Button", nil, menu)
    row._hl = row:CreateTexture(nil, "BACKGROUND", nil, 1)
    row._hl:SetAllPoints()
    row._lbl = row:CreateFontString(nil, "OVERLAY")
    row._lbl:SetFont(fontPath, 11, "")
    row._lbl:SetPoint("LEFT", row, "LEFT", 8, 0)
    row._lbl:SetJustifyH("LEFT")
    row._arrow = row:CreateTexture(nil, "ARTWORK")
    row._arrow:SetTexture(CTX_ARROW_ICON)
    row._arrow:SetSize(19, 19)
    row._arrow:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    row._arrow:SetRotation(math.pi / 2)
    row._arrow:SetVertexColor(1, 1, 1, 0.75)
    row._arrow:Hide()
    row._sep = row:CreateTexture(nil, "ARTWORK")
    row._sep:SetHeight(1)
    row._sep:SetPoint("LEFT", row, "LEFT", 6, 0)
    row._sep:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row._sep:SetColorTexture(1, 1, 1, 0.12)
    row._sep:SetPoint("CENTER")
    row._sep:Hide()
    menu._pool[idx] = row
    return row
end

local function LayoutMenu(menu, items, onDismiss, isChild)
    local fontPath = GetFont()
    local hlAlpha = 0.08
    for _, r in ipairs(menu._pool) do
        r:Hide()
    end
    if not menu._mfs then
        menu._mfs = menu:CreateFontString(nil, "OVERLAY")
    end
    menu._mfs:SetFont(fontPath, 11, "")
    local maxW = 0
    for _, item in ipairs(items) do
        if type(item) == "table" and item.text then
            local extra = ""
            if item.timerText then extra = "  " .. item.timerText end
            menu._mfs:SetText(item.text .. extra)
            local w = menu._mfs:GetStringWidth() or 0
            if w > maxW then maxW = w end
        end
    end
    menu._mfs:SetText("")
    menu._mfs:Hide()
    local menuW = math.max(100, maxW + 50)
    local y = 0
    for idx, item in ipairs(items) do
        local row = EnsureMenuRow(menu, idx)
        row._sep:Hide()
        row._arrow:Hide()
        row._hl:SetColorTexture(1, 1, 1, 0)
        if item == "---" then
            row:SetSize(menuW, 7)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", menu, "TOPLEFT", 0, y)
            row._lbl:SetText("")
            row._sep:Show()
            row:EnableMouse(false)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row:SetScript("OnClick", nil)
            row:Show(); y = y - 7
        elseif item.isHeader then
            row:SetSize(menuW, 20)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", menu, "TOPLEFT", 0, y)
            row._lbl:SetFont(fontPath, 11, "")
            row._lbl:SetPoint("RIGHT", row, "RIGHT", -8, 0)
            row._lbl:SetText(item.text)
            row._lbl:SetTextColor(1, 0.82, 0, 1)
            row:EnableMouse(false)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row:SetScript("OnClick", nil)
            row:Show(); y = y - 20
        else
            local rowH = item.compact and (22 - 2) or 22
            row:SetSize(menuW, rowH)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", menu, "TOPLEFT", 0, y)
            row._lbl:SetFont(fontPath, 11, "")
            row._lbl:SetText(item.text or "")
            row:EnableMouse(true)
            -- Inline input field (e.g. width entry)
            if item.isInput then
                row._lbl:SetTextColor(1, 1, 1, 1)
                row:EnableMouse(false)
                row:SetScript("OnEnter", nil)
                row:SetScript("OnLeave", nil)
                row:SetScript("OnClick", nil)
                if not row._editBox then
                    local box = CreateFrame("EditBox", nil, row)
                    box:SetSize(50, 18)
                    box:SetPoint("RIGHT", row, "RIGHT", -8, 0)
                    box:SetFrameLevel(row:GetFrameLevel() + 3)
                    box:SetFont(fontPath, 10, "")
                    box:SetTextColor(1, 1, 1, 0.9)
                    box:SetJustifyH("CENTER")
                    local boxBg = box:CreateTexture(nil, "BACKGROUND")
                    boxBg:SetAllPoints()
                    boxBg:SetColorTexture(0, 0, 0, 0.4)
                    box:SetAutoFocus(false)
                    box:SetNumeric(true)
                    box:SetMaxLetters(5)
                    row._editBox = box
                end
                row._editBox:Show()
                row._editBox:SetNumber(item.getValue and item.getValue() or 0)
                row._editBox:SetScript("OnEnterPressed", function(self)
                    local val = math.max(item.min or 1, math.floor(self:GetNumber() + 0.5))
                    self:SetNumber(val)
                    if item.setValue then item.setValue(val) end
                    self:ClearFocus()
                end)
                row._editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
                row:Show(); y = y - rowH
            end
            if item.isInput then -- skip normal item logic
            else
            local disabled = item.isDisabled and item.isDisabled()
            if item.children then
                row._arrow:SetVertexColor(1, 1, 1, disabled and 0.2 or 0.75)
                row._arrow:Show()
            end
            if disabled then
                row._lbl:SetTextColor(0.4, 0.4, 0.4, 0.5)
                row:SetScript("OnEnter", function()
                    if not isChild and _contextMenuSub then
                        _contextMenuSub:Hide()
                    end
                end)
                row:SetScript("OnLeave", nil)
                row:SetScript("OnClick", nil)
            else
                local active = item.isActive
                row._lbl:SetTextColor(1, 1, 1, 1)
                if active then
                    row._hl:SetColorTexture(1, 1, 1, hlAlpha)
                    row._hl:Show()
                end
                local itemRef = item
                row:SetScript("OnEnter", function(self)
                    self._hl:SetColorTexture(1, 1, 1, hlAlpha)
                    -- if itemRef.tooltip and EUI.ShowWidgetTooltip then
                    --     EUI.ShowWidgetTooltip(self, itemRef.tooltip)
                    -- end
                    if itemRef.children then
                        if not _contextMenuSub then
                            _contextMenuSub = MakeMenuPanel(1)
                        end
                        LayoutMenu(_contextMenuSub, itemRef.children, onDismiss, true)
                        _contextMenuSub:ClearAllPoints()
                        local right = self:GetRight()
                        local subW = _contextMenuSub:GetWidth()
                        local screenW = UIParent:GetRight()
                        if right and subW and screenW and (right + subW) > screenW then
                            _contextMenuSub:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
                        else _contextMenuSub:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0) end
                        _contextMenuSub:Show()
                    elseif not isChild and _contextMenuSub then
                        _contextMenuSub:Hide()
                    end
                end)
                row:SetScript("OnLeave", function(self)
                    -- if EUI.HideWidgetTooltip then
                    --     EUI.HideWidgetTooltip()
                    -- end
                    self._hl:SetColorTexture(1, 1, 1, active and hlAlpha or 0)
                    self._lbl:SetTextColor(1, 1, 1, 1)
                    if isChild then return end
                    if _contextMenuSub and _contextMenuSub:IsShown() and _contextMenuSub:IsMouseOver() then return end
                    if _contextMenuSub and itemRef.children then
                        _contextMenuSub:Hide()
                    end
                end)
                row:SetScript("OnClick", function()
                    if itemRef.children then return end
                    if itemRef.onClick then
                        itemRef.onClick()
                    end
                    if onDismiss then
                        onDismiss()
                    end
                end)
            end
            if row._editBox then
                row._editBox:Hide()
            end
            row:Show(); y = y - rowH
            end -- close isInput else
        end
    end
    menu:SetSize(menuW, math.abs(y))
end

local function ShowContextMenu(items, anchorBtn)
    if not _contextMenu then
        _contextMenu = MakeMenuPanel(0)
        local acc = 0
        _contextMenu:SetScript("OnUpdate", function(self, dt)
            acc = acc + dt; if acc < 0.1 then return end; acc = 0
            local over = self:IsMouseOver()
                or (_contextMenuSub and _contextMenuSub:IsShown() and _contextMenuSub:IsMouseOver())
                or (_contextMenuAnchor and _contextMenuAnchor:IsMouseOver())
            if not over and IsMouseButtonDown("LeftButton") then
                self:Hide()
            end
        end)
        _contextMenu:HookScript("OnHide", function()
            if _contextMenuSub then
                _contextMenuSub:Hide()
            end
            _contextMenuAnchor = nil
        end)
    end

    -- Toggle: if same button clicked again while menu is open, close it
    if anchorBtn and _contextMenu:IsShown() and _contextMenuAnchor == anchorBtn then
        _contextMenu:Hide()
        return
    end

    local function dismiss()
        _contextMenu:Hide()
        if _contextMenuSub then
            _contextMenuSub:Hide()
        end
    end

    LayoutMenu(_contextMenu, items, dismiss)
    _contextMenu:ClearAllPoints()
    if anchorBtn then
        _contextMenu:SetPoint("BOTTOMRIGHT", anchorBtn, "TOPRIGHT", 0, 0)
    else
        local scale = _contextMenu:GetEffectiveScale(); local cx, cy = GetCursorPosition()
        _contextMenu:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", cx / scale, cy / scale)
    end
    _contextMenuAnchor = anchorBtn
    _contextMenu:Show()
end

addonTable.ApplyWinPosition = function(frame, wdb, idx)
    local pos = wdb.position
    frame:ClearAllPoints()
    if pos and pos.x and pos.y then
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", pos.x, pos.y)
    else
        -- Default: 20px from bottom-right of screen, cascading per window
        local uiW, uiH = UIParent:GetSize()
        local fw, fh = frame:GetSize()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
            uiW/2 - fw/2 - 20 + (idx - 1) * 20, uiH/2 + fh/2 + 20 - (idx - 1) * 20)
    end
end


local function GetHeaderLayoutButtons(window)
    local buttons = {}
    if not window or not window.headerBtn then return buttons end
    for _, btn in ipairs(window.headerBtn) do
        buttons[#buttons + 1] = btn
    end
    return buttons
end

local function LayoutHeaderButtons(window, iconSz)
    if not window or not window.header or not window.headerBtn then return end
    local btnPad = -2
    local layoutBtns = GetHeaderLayoutButtons(window)
    for bi, btn in ipairs(layoutBtns) do
        if iconSz then btn:SetSize(iconSz, iconSz) end
        btn:ClearAllPoints()
        btn:SetPoint("RIGHT", window.header, "RIGHT", -(iconSz * (bi - 1) + btnPad * bi + 2), 0)
    end
end

local function CreateProfessionFrame(idx, category)
    local wCfg = GetWindowConfig(category)

    local window = {}
    window.idx = idx
    window.category = wCfg.category or category
    window.windowLocked = wCfg.locked or false

    local frame = CreateFrame("Frame", "GatherOverview_" .. category, UIParent)
	frame:SetSize(wCfg.width or 300, wCfg.height or 200)
    frame:SetClampedToScreen(true) -- frame cannot move outside the screen
    frame:SetMovable(true)
    window.frame = frame

    addonTable.ApplyWinPosition(frame, wCfg, idx)

    window.ApplyPosition = function()
        addonTable.ApplyWinPosition(frame, wCfg, window.idx)
    end

    frame._bg = frame:CreateTexture(nil, "BACKGROUND")
    frame._bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -headerHeight)
    frame._bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    local bg_color = addonTable.Config.Get(addonTable.Config.Options.BG_COLOR)
    frame._bg:SetColorTexture(bg_color.r or 0, bg_color.g or 0, bg_color.b or 0, bg_color.a or 0.75)

    ---------------------------------------------------------------------------
    --  Header
    ---------------------------------------------------------------------------
    local header = CreateFrame("Frame", nil, frame)
    header:SetHeight(headerHeight)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    header:SetFrameLevel(frame:GetFrameLevel() + 5)
    header._hdrBg = header:CreateTexture(nil, "BACKGROUND")
    header._hdrBg:SetAllPoints()
    header._hdrBg:SetColorTexture(bg_color.r, bg_color.g, bg_color.b, bg_color.a or 1)
    window.header = header

    local professionTranslation = addonTable.ProfessionTranslate[category]
    window.titleText = header:CreateFontString(nil, "OVERLAY")
    local fontSize = addonTable.Config.Get(addonTable.Config.Options.HEADER_FONT_SIZE) or 11
    window.titleText:SetFont(GetFont(), fontSize, "OUTLINE")
    window.titleText:SetPoint("LEFT", header, "LEFT", 6)
    window._fullTitle = professionTranslation
    window.titleText:SetText(professionTranslation)

    ---------------------------------------------------------------------------
    --  Header buttons
    ---------------------------------------------------------------------------
    local btnSize = addonTable.Config.Get(addonTable.Config.Options.HEADER_ICON_SIZE) or 22
    local btnPad = 2
    window.headerBtn = {}
    window.headerIcons = {}
    -- Add here a button to change profession
    -- It should allow to change to available profession only
    local function MakeHeaderBtn(texFile, xOff, tooltip, onClick)
        local btn = CreateFrame("Button", nil, header)
        btn:SetSize(btnSize, btnSize)
        btn:SetPoint("RIGHT", header, "RIGHT", xOff, 0)
        btn:SetFrameLevel(header:GetFrameLevel() + 2)

        local icon = btn:CreateTexture(nil, "ARTWORK"); icon:SetAllPoints()
        icon:SetTexture(IMAGES..texFile)
        icon:SetDesaturated(true)
        icon:SetVertexColor(1, 1, 1, .4)

        window.headerIcons[#window.headerIcons + 1] = icon
        btn:SetScript("OnEnter", function(self)
            icon:SetVertexColor(1, 1, 1, .9)
            -- show tooltip
        end)
        btn:SetScript("OnLeave", function()
            icon:SetVertexColor(1, 1, 1, .4)
            -- hide tooltip
        end)
        btn:SetScript("OnClick", function(self)
            -- hide tooltip before exec to onClick
            onClick(self)
        end)
        return btn
    end

    window.settingsBtn = MakeHeaderBtn("cog.png", 0, "Settings", function()
        ShowContextMenu({
            { text = L.SHOW_IN_INSTANCES, isActive = not wCfg.hideInInstance, onClick = function()
                wCfg.hideInInstance = not wCfg.hideInInstance
                for _, w in ipairs(_windows) do
                    w.UpdateVisibility()
                end
            end },
            { text = L.SHOW_IN_COMBAT, isActive = not wCfg.hideDuringCombat, onClick = function()
                wCfg.hideDuringCombat = not wCfg.hideDuringCombat
                for _, w in ipairs(_windows) do
                    w.UpdateVisibility()
                end
            end },
            { text = L.DISPLAY_IN_REPO_ZONE, isActive = not wCfg.hideInRestingZone, onClick = function()
                wCfg.hideInRestingZone = not wCfg.hideInRestingZone
                for _, w in ipairs(_windows) do
                    w.UpdateVisibility()
                end
            end },
            "---",
            { text = L.WIDTH, isInput = true,
              getValue = function() return math.floor(frame:GetWidth() + 0.5) end,
              setValue = function(v)
                  local left, top = frame:GetLeft(), frame:GetTop()
                  frame:SetSize(math.max(MIN_W, v), frame:GetHeight())
                  if left and top then
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
                  end
                  wCfg.width = math.floor(frame:GetWidth() + 0.5)
                  SaveWindowConfig(category, wCfg)
              end,
              min = MIN_W },
            { text = L.HEIGHT, isInput = true,
              getValue = function() return math.floor(frame:GetHeight() + 0.5) end,
              setValue = function(v)
                  local left, top = frame:GetLeft(), frame:GetTop()
                  frame:SetSize(frame:GetWidth(), math.max(MIN_H, v))
                  if left and top then
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
                  end
                  wCfg.height = math.floor(frame:GetHeight() + 0.5)
                  SaveWindowConfig(category, wCfg)
              end,
              min = MIN_H },
        }, window.settingsBtn)
    end)

    local winActionIcon = (idx == 1) and (IMAGES.."open.png") or (IMAGES.."close.png")
    local winActionTip = (idx == 1) and L.NEW_WINDOW or L.CLOSE_WINDOW
    window.actionBtn = MakeHeaderBtn("cog.png", -(btnSize + btnPad), winActionTip, function()
        if idx ~= 1 and window.windowLocked then return end
        if idx == 1 then
            if tLength(_windows) >= MAX_WINDOWS then return end
            local srcW2 = frame:GetWidth()
            local srcH2 = frame:GetHeight()
            local srcLeft2 = frame:GetLeft()
            local GAP = 10

            -- Find the highest top and lowest bottom among all existing windows
            local highestTop = frame:GetTop() or 0
            local lowestBot = frame:GetBottom() or 0
            for _, w in ipairs(_windows) do
                if w.frame then
                    local t = w.frame:GetTop()
                    local b = w.frame:GetBottom()
                    if t and t > highestTop then highestTop = t end
                    if b and b < lowestBot then lowestBot = b end
                end
            end

            -- Try above first: new window bottom = highest top + gap
            local screenTop2 = UIParent:GetTop() or 0
            local newTop2 = highestTop + srcH2 + GAP
            if newTop2 > screenTop2 then
                -- No room above: place below the lowest window
                newTop2 = lowestBot - GAP
            end
            local enabledCategories = GetSortedProfessions()
            for i, cat in ipairs(enabledCategories) do
                if not _windows[cat] then
                    _windows[cat] = CreateProfessionFrame(i, cat)
                    _windows[cat].width = math.floor(srcW2 + 0.5)
                    _windows[cat].height = math.floor(srcH2 + 0.5)
                    _windows[cat].position = { x = srcLeft2, y = newTop2 }
                    break
                end
            end
        else
            window.Destroy()
        end
    end)

    -- Override icon texture; 
    -- close icon 2px larger for visibility
    do
        local iconTex = window.headerIcons[#window.headerIcons]
        iconTex:SetTexture(winActionIcon)
        if idx ~= 1 then window._closeIconTex = iconTex end
        if idx ~= 1 then
            iconTex:ClearAllPoints()
            iconTex:SetSize(btnSize + 2, btnSize + 2)
            iconTex:SetPoint("CENTER", window.actionBtn, "CENTER", 0, 0)
        end
        -- Disable + button at max windows / close button when locked
        if idx == 1 then
            window.actionBtn:HookScript("OnEnter", function(self)
                if tLength(_windows) >= MAX_WINDOWS then
                    iconTex:SetAlpha(0.2)
                    -- TOOLTIP
                end
            end)
        else
            window.actionBtn:HookScript("OnEnter", function(self)
                if window.windowLocked then
                    iconTex:SetVertexColor(1, 1, 1, .9)
                    -- TOOLTIP
                end
            end)
            window.actionBtn:HookScript("OnLeave", function()
                if window.windowLocked then
                    iconTex:SetVertexColor(1, 1, 1, .9)
                end
            end)
        end
    end
    -- Apply initial close icon dimming if window starts locked
    if idx ~= 1 and window.windowLocked and window._closeIconTex then
        window._closeIconTex:SetVertexColor(1, 1, 1, .9)
    end

    window.headerBtn = { window.actionBtn, window.settingsBtn }
    LayoutHeaderButtons(window, btnSize)

    header:EnableMouse(true)
    local dragging = false
    local dragStartCX, dragStartCY, dragStartLeft, dragStartTop
    local dragFrame = CreateFrame("Frame")
    dragFrame:Hide()
    dragFrame:SetScript("OnUpdate", function()
        if not dragging then return end
        if not IsMouseButtonDown("LeftButton") then
            dragging = false
            dragFrame:Hide()
            SaveWindowPosition(category, frame)
        end
        local cx, cy = GetCursorPosition()
        local es = frame:GetEffectiveScale()
        local newLeft = dragStartLeft + (cx/es - dragStartCX)
        local newTop = dragStartTop + (cy/es - dragStartCY)

        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", newLeft, newTop)
        SaveWindowPosition(category, frame)
    end)

    header:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or window.windowLocked then return end
        if not window.hideInInstance and IsInInstance() then return end
        local cx, cy = GetCursorPosition()
        local es = frame:GetEffectiveScale()
        dragStartCX = cx/es
        dragStartCY = cy/es
        dragStartLeft = frame:GetLeft()
        dragStartTop = frame:GetTop()
        if not dragStartLeft or not dragStartTop then return end
        dragging = true
        dragFrame:Show()
    end)
    header:SetScript("OnMouseUp", function(_, button)
        -- Right-click on the header toggles the meter-type home screen,
        -- matching the right-click behavior of the window body.
        if button ~= "LeftButton" or not dragging then return end
        dragging = false
        dragFrame:Hide()

        SaveWindowPosition(category, frame)
    end)
    ---------------------------------------------------------------------------
    --  Frame content
    ---------------------------------------------------------------------------
    local professionSetting = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    local showTotal = addonTable.Config.Get(addonTable.Config.Options.SHOW_TOTAL)
    local itemsPerRow = addonTable.Config.Get(addonTable.Config.Options.ROW_AMOUNT)

    local items = addonTable.MainFrame.Counts[category]
    -- Display the icons of the current profession
    window.icons = {}
    window.subHeaderText = {}

    -- Helper: Update icon display (text, color, position, tooltip)
    local function UpdateIconDisplay(itemID, displayValue, message, iconWidth, iconHeight, colIcon, rowIconY)
        if not window.icons[itemID] then
            window.icons[itemID] = CreateIcon(window.frame, itemID)
        end
        window.icons[itemID]:SetSize(iconWidth, iconHeight)
        local iconX = 10 + colIcon * (iconWidth + iconSpacingX)
        window.icons[itemID]:SetPoint("TOPLEFT", window.frame, "TOPLEFT", iconX, rowIconY)
        window.icons[itemID].text:SetText(tostring(GetCountValue(displayValue)))
        
        local color = addonTable.Colors.GetColorForValue(professionTranslation, displayValue)
        window.icons[itemID].text:SetTextColor(color.r, color.g, color.b, color.a)
        window.icons[itemID]:Show()
        UpdateToolTip(window.icons[itemID], itemID, message)
    end

    -- Helper: Advance layout position
    local function AdvanceLayoutPos(state, iconHeight)
        state.colIcon = state.colIcon + 1
        if state.colIcon >= itemsPerRow then
            state.colIcon = 0
            state.rowIconY = state.rowIconY - (iconHeight + 20)
            state.rowCount = state.rowCount + 1
            state.fullRow = true
        end
    end

    function window.Refresh()
        if not frame then return end
        local iconWidth = professionSetting[category].icon_width
        local iconHeight = professionSetting[category].icon_height
        local state = { colIcon = 0, rowIconY = -35, rowCount = 0, fullRow = false }
        
        items = addonTable.MainFrame.Counts[window.category]
        if window.category == "OTHER_STUFF" then
            local prevSubCategory = ""
            for _, info in ipairs(items) do
                local item = info[4] -- get the full item data
                local profName = addonTable.Config.GetProfessionNameFromIndex(item.profession)
                if addonTable.Core.learnedProfessions[profName] then
                    -- Handle sub-category header
                    if profName ~= prevSubCategory then
                        prevSubCategory = profName
                        local offsetY = -35
                        if state.rowCount > 0 then
                            offsetY = state.rowCount * (state.fullRow and state.rowIconY or (state.rowIconY - (iconHeight + 20)))
                        end
                        state.rowIconY = offsetY
                        state.colIcon = 0
                        state.fullRow = false
                    end

                    local bagCount = info[2]
                    local total = info[3]
                    local displayCount = showTotal and total or bagCount
                    if item.profession == addonTable.Constants.OTHER_STUFF then
                        local message = L.IN_BAGS .. ": " .. bagCount .. "\n" .. L.IN_BANK .. ": " .. (total - bagCount) .. "\n" .. L.TOTAL .. ": " .. total
                        UpdateIconDisplay(item.id, displayCount, message, iconWidth, iconHeight, state.colIcon, state.rowIconY)
                        AdvanceLayoutPos(state, iconHeight)
                    else
                        local totalToCatch = 1
                        if item.curencyId then
                            local quantity = GetCatchUpCurrencyLeft(item.curencyId)
                            totalToCatch = quantity.max - quantity.quantity
                        end
                        if item.questId then
                            totalToCatch = GetMissingCurrencyFromQuest(item)
                        end
                        
                        if totalToCatch == 0 and window.icons[item.id] then
                            window.icons[item.id]:Hide()
                        else
                            local message = L.STILL_TO_GET .. ": " .. totalToCatch
                            UpdateIconDisplay(item.id, totalToCatch, message, iconWidth, iconHeight, state.colIcon, state.rowIconY)
                            AdvanceLayoutPos(state, iconHeight)
                        end
                    end
                end
            end
        else
            for _, info in ipairs(items) do
                local itemID = info[1]
                local count = info[2]
                local total = info[3]
                local displayCount = showTotal and total or count
                local message = L.IN_BAGS .. ": " .. count .. "\n" .. L.IN_BANK .. ": " .. (total - count) .. "\n" .. L.TOTAL .. ": " .. total
                
                UpdateIconDisplay(itemID, displayCount, message, iconWidth, iconHeight, state.colIcon, state.rowIconY)
                AdvanceLayoutPos(state, iconHeight)
            end
        end
        
        wCfg.width = (iconWidth + iconSpacingX) * itemsPerRow + iconSpacingX
        wCfg.height = -1 * (state.rowIconY - (iconHeight + 20 + 20))
        frame:SetSize(wCfg.width, wCfg.height)
    end

    ---------------------------------------------------------------------------
    --  Visibility
    ---------------------------------------------------------------------------
    function window.UpdateVisibility()
        if not frame then return end

        -- save configuration 
        SaveWindowConfig(category, wCfg)
        -- Per-window instance visibility
        if (wCfg.hideInInstance and IsInInstance()) or
           (wCfg.hideInRestingZone and IsResting()) or
           (wCfg.hideDuringCombat and PlayerIsInCombat()) then
            frame:Hide()
            return
        end

        frame:SetAlpha(1)
        frame:EnableMouse(true)
        frame:Show()
    end


    window.UpdateVisibility()

    ---------------------------------------------------------------------------
    --  DESTROY
    ---------------------------------------------------------------------------
    function window.Destroy()
        frame:Hide()
        frame:SetParent(nil)
        -- Remove from runtime array
        local runtimeCategory
        for _, w in pairs(_windows) do
            if w == window then
                runtimeCategory = w.category
                break
            end
        end
        if runtimeCategory then
            wipe(_windows[runtimeCategory])
            _windows[runtimeCategory] = nil
        end
    end

    -- Defer initial refresh off the init frame
    C_Timer.After(0, function()
        window.Refresh()
    end)

    return window
end

--------------------------------------------------
--- API
--------------------------------------------------

function addonTable.MainFrame.Initialize()

    addonTable.MainFrame.ScanBags()

    local enabledCategories = GetSortedProfessions()
    MAX_WINDOWS = tLength(enabledCategories) + 1 -- +1 for Misc elements

    for i = 1, MAX_WINDOWS do
        _windows[i] = nil
    end

    for i, category in ipairs(enabledCategories) do
        _windows[category] = CreateProfessionFrame(i, category)
    end
end

function addonTable.MainFrame.UpdateUI()
    if tLength(_windows) == 0 then
        addonTable.MainFrame.Initialize()
        return
    end

    for _, w in pairs(_windows) do
        w.Refresh()
        w.UpdateVisibility()
    end
end

function addonTable.MainFrame.ScanBags()
    wipe(addonTable.MainFrame.Counts)
    -- Do nothing if not retail
    if not addonTable.Constants.IsRetail then return end

    local isMidnight = addonTable.Constants.IsMidnight
    for category, itemList in pairs(addonTable.ItemDB) do
        addonTable.MainFrame.Counts[category] = {}
        for _, itemData in ipairs(itemList) do
            local itemId = itemData.id
            local ext = itemData.extension
            -- If Midnight build: only include items with extension MN
            -- Otherwise include items that are not MN
            if (isMidnight and ext == addonTable.Constants.EXT_MN) or (not isMidnight and ext ~= addonTable.Constants.EXT_MN) then
                local count = C_Item.GetItemCount(itemId)
                local total = C_Item.GetItemCount(itemId, true, nil, true, true)
                table.insert(addonTable.MainFrame.Counts[category], {itemId, count, total, itemData})
            end
        end
    end
end