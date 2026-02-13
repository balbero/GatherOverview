---@class addonTableGatherOverview
local addonTable = select(2, ...)
addonTable.MainFrame = {}
addonTable.MainFrame.labels = {}
addonTable.MainFrame.Counts = {}

local function Nop(...)
end
GetItemReagentQualityInfo = C_TradeSkillUI and C_TradeSkillUI.GetItemReagentQualityInfo or Nop

local headerHeight = 20
local iconSpacingX = 10
local frameWidth = 350
local frameHeight = 800
local sectionXSpacing = 10


local function ShouldHideFrame()
    local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    local showFrame = professionsConfig.MINING.enabled or
                      professionsConfig.HERBALISM.enabled or
                      professionsConfig.SKINNING.enabled or
                      (professionsConfig.FISHING.enabled and professionsConfig.FISHING.display)

    return (IsInInstance() and addonTable.Config.Get(addonTable.Config.Options.SHOW_IN_INSTANCES) == false) or
        (IsResting() and addonTable.Config.Get(addonTable.Config.Options.DISPLAY_IN_REPO_ZONE) == false) or
        (PlayerIsInCombat() and addonTable.Config.Get(addonTable.Config.Options.SHOW_IN_COMBAT) == false) or
        not showFrame or
        not addonTable.Constants.IsRetail
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
        
    -- Collect enabled and learned categories
    local enabledCategories = {}
    for category, _ in pairs(addonTable.MainFrame.Counts) do
        local professionTranslation = addonTable.ProfessionTranslate[category]
        local display = false
        for _, prof in pairs(professionSetting) do
            if professionTranslation == prof.name then
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
        local order = {MINING = 1, HERBALISM = 2, SKINNING = 3, FISHING = 4}
        return order[a] < order[b]
    end)
    return enabledCategories
end

local function isFishingOnlyDisplayable()
    local professionSetting = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    local fishingEnabled = (professionSetting.FISHING.enabled and professionSetting.FISHING.display)
    local otherEnabled = professionSetting.MINING.enabled or
                      professionSetting.HERBALISM.enabled or
                      professionSetting.SKINNING.enabled
    return fishingEnabled and not otherEnabled
end

function addonTable.MainFrame.RefreshLabels()
    for itemID, data in pairs(addonTable.MainFrame.labels) do
        local count = C_Item.GetItemCount(itemID)
        data.label:SetText(tostring(count))
        local color = addonTable.Colors.GetColorForValue(data.prof, count)
        data.label:SetColor(color.r, color.g, color.b, color.a)
    end
end

function addonTable.MainFrame.ToggleIfNeeded()
    
    if ShouldHideFrame() then
        addonTable.MainFrame.frame:Hide()
        return
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    -- Check upon the blacklisted zone ID
    -- if mapID is in the blacklist
    -- then hide the MainFrame
    -- otherwise show it
    local hide = false
    for _, zoneID in pairs(addonTable.blacklistedZone) do
        if zoneID == mapID then
            hide = true
            break
        end
    end
    
    local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)

    local showFrame = professionsConfig.MINING.enabled or
                      professionsConfig.HERBALISM.enabled or
                      professionsConfig.SKINNING.enabled or
                      (professionsConfig.FISHING.enabled and professionsConfig.FISHING.display)

    if hide or showFrame == false then
        addonTable.MainFrame.frame:Hide()
    else
        addonTable.MainFrame.frame:Show()
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

function addonTable.MainFrame.Initialize()
    local header_size = 20
    -- Create the Main panel
    local frame = CreateFrame("frame", "GatherOverview_MainFrame", UIParent, "BackdropTemplate")
    frame:SetPoint("TOP", UIParent, "TOP", 0, -110)
	frame:SetSize(frameWidth, frameHeight)
    frame:SetBackdrop(
    {
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
        tile = true,
        tileSize = 16,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0}
    })
    local bg_color = addonTable.Config.Get(addonTable.Config.Options.BG_COLOR)
    frame:SetBackdropColor(bg_color.r, bg_color.g, bg_color.b, bg_color.a)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true) -- frame cannot move outside the screen
    
    frame:SetFrameStrata("BACKGROUND")  -- reduce the z-level to be behind wow UI element

    local TitleString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    TitleString:SetPoint("TOP", frame, "TOP", 0, -5)
    TitleString:SetText(addonTable.Locales.GATHER_OVERVIEW)
    addonTable.Utilities.SetFontSize(TitleString, 9)
    local TitleBackground = frame:CreateTexture(nil, "ARTWORK")
    TitleBackground:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
    TitleBackground:SetVertexColor(.1, .1, .1, .9)
    TitleBackground:SetVertexColor(.1, .1, .1, 0)
    TitleBackground:SetPoint("TOPLEFT", frame, "TOPLEFT")
    TitleBackground:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    TitleBackground:SetHeight(header_size)

    local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)

    local showFrame = professionsConfig.MINING.enabled or professionsConfig.HERBALISM.enabled or professionsConfig.SKINNING.enabled or professionsConfig.FISHING.enabled

    frame:RegisterForDrag("LeftButton")
    frame:SetPassThroughButtons("RightButton", "MiddleButton", "Button4", "Button5")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    addonTable.MainFrame.frame = frame
    addonTable.MainFrame.icons = { }
    addonTable.MainFrame.headers = { }

    if showFrame then
        frame:Show()
    else
        frame:Hide()
    end
end

function addonTable.MainFrame.CreateIcon(parent, itemId)
    local button = CreateFrame("Frame", nil, parent)
    -- button:SetSize(iconW, iconH)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(C_Item.GetItemIconByID(itemId))
    local info = GetItemReagentQualityInfo(itemId)

    if info and info.icon then
        local qualityText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        qualityText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        local text = "|A:"..info.icon..":20:20|a"
        qualityText:SetText(text)
    end

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOP", button, "BOTTOM", 0, -5)

    button.icon = icon
    button.text = text

    return button
end

function addonTable.MainFrame.UpdateUI()
    if not addonTable.MainFrame.frame then
        addonTable.MainFrame.Initialize()
    end

    if ShouldHideFrame() then
        addonTable.MainFrame.frame:Hide()
        return
    end

    if addonTable.MainFrame.frame:IsShown() == false then
        addonTable.MainFrame.frame:Show()
    end
    
    local enabledCategories = GetSortedProfessions()
    
    -- no profession to display
    if tLength(enabledCategories) == 0 then
        addonTable.MainFrame.frame:Hide()
        return
    end

    -- Assign positions: first two in row 0 (col 0 and 1), Fishing in row 1 col 0
    local positions = {}
    local topRow = {}
    for _, category in ipairs(enabledCategories) do
        if category == "FISHING" then
            table.insert(positions, {cat = category, col = 0, row = 1})
        elseif tLength(topRow) < 2 then
            table.insert(topRow, category)
        end
    end
    -- Assign top row positions
    for i, category in ipairs(topRow) do
        table.insert(positions, {cat = category, col = i-1, row = 0})
    end

    table.sort(positions, function(a, b)
        return (2*a.row+a.col) < (2*b.row+b.col)
    end)

    local professionSetting = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    local showTotal = addonTable.Config.Get(addonTable.Config.Options.SHOW_TOTAL)
    local itemsPerRow = addonTable.Config.Get(addonTable.Config.Options.ROW_AMOUNT)
    local displayFishing = professionSetting.FISHING.display

    -- Now position the categories
    local rowIconY = 0
    
    --reset frameWidth and frameHeight cause we have profession !!
    frameWidth = 0
    frameHeight = 0

    local prevSectionWidth = 0
    local prevRowIconY = 0

    for _, pos in ipairs(positions) do
        local category = pos.cat
        local items = addonTable.MainFrame.Counts[category]
        local professionTranslation = addonTable.ProfessionTranslate[category]
        local colIcon = 0
        local sectionWidth = (professionSetting[category].icon_width + iconSpacingX) * itemsPerRow  + sectionXSpacing

        local x = 10 + pos.col * prevSectionWidth
        local y = -35 + pos.row * (prevRowIconY - headerHeight)
        local iconY = y - headerHeight
        rowIconY = iconY
        -- Create or reposition header
        if not addonTable.MainFrame.headers[category] then
            local header = addonTable.MainFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header:SetPoint("TOPLEFT", addonTable.MainFrame.frame, "TOPLEFT", x, y)
            header:SetText(professionTranslation)
            addonTable.MainFrame.headers[category] = header
        else
            addonTable.MainFrame.headers[category]:SetPoint("TOPLEFT", addonTable.MainFrame.frame, "TOPLEFT", x, y)
            if category == "FISHING" and displayFishing == false then
                addonTable.MainFrame.headers[category]:Hide()
            else
                addonTable.MainFrame.headers[category]:Show()
            end
        end
        for _, info in ipairs(items) do
            local itemID = info[1]
            local count = info[2]
            local total = info[3]
            if C_Item.GetItemInfo(itemID) then
                local iconWidth = professionSetting[category].icon_width
                local iconHeight = professionSetting[category].icon_height
                if not addonTable.MainFrame.icons[itemID] then
                    addonTable.MainFrame.icons[itemID] = addonTable.MainFrame.CreateIcon(addonTable.MainFrame.frame, itemID)
                end
                addonTable.MainFrame.icons[itemID]:SetSize(iconWidth, iconHeight)

                local iconX = x + colIcon * (iconWidth + iconSpacingX)
                addonTable.MainFrame.icons[itemID]:SetPoint("TOPLEFT", addonTable.MainFrame.frame, "TOPLEFT", iconX, rowIconY)
                if category == "FISHING" and displayFishing == false then
                    addonTable.MainFrame.icons[itemID]:Hide()
                else
                    addonTable.MainFrame.icons[itemID]:Show()
                end
                local displayCount = count
                if showTotal then
                    displayCount = total
                end
                addonTable.MainFrame.icons[itemID].text:SetText(tostring(displayCount))
                local colorForProfession = addonTable.Colors.GetColorForValue(professionTranslation, displayCount)
                addonTable.MainFrame.icons[itemID].text:SetTextColor(colorForProfession.r, colorForProfession.g, colorForProfession.b, colorForProfession.a)
                colIcon = colIcon + 1
                if colIcon >= itemsPerRow then
                    colIcon = 0
                    rowIconY = rowIconY - (iconHeight + 20)
                end
            end
        end
        if category == "FISHING" and displayFishing == false then
            rowIconY = prevRowIconY
        end
        if pos.row == 0 or isFishingOnlyDisplayable() then
            frameWidth = frameWidth + sectionWidth
        end
        -- numbers are negative here
        if prevRowIconY > rowIconY then
            frameHeight = rowIconY - (professionSetting[category].icon_height + 20 + 20) -- text and padding
            prevRowIconY = rowIconY
        end
        prevSectionWidth = sectionWidth
    end
    if frameWidth ~= 0 and frameHeight ~= 0 then
        addonTable.MainFrame.frame:SetSize(frameWidth, -frameHeight)
    end
end