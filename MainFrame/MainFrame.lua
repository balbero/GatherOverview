---@class addonTableGatherOverview
local addonTable = select(2, ...)
local AceGUI = LibStub("AceGUI-3.0")

addonTable.MainFrame = {}
addonTable.MainFrame.labels = {}
addonTable.MainFrame.Counts = {}

local itemsPerRow = 3  -- Nombre d'icônes par ligne
local iconSize = 32    -- Taille des icônes
local headerHeight = 20
local iconSpacingX = 10
local sectionWidth = 180
local sectionXSpacing = 10

function addonTable.MainFrame.RefreshLabels()
    for itemID, data in pairs(addonTable.MainFrame.labels) do
        local count = C_Item.GetItemCount(itemID)
        data.label:SetText(tostring(count))
        local color = addonTable.Colors.GetColorForValue(data.prof, count)
        data.label:SetColor(color.r, color.g, color.b, color.a)
    end
end

function addonTable.MainFrame.ToggleIfNeeded()
    local inInstance, _ = IsInInstance()
    if inInstance and addonTable.Config.Get("ShowInInstances") == false then
        addonTable.MainFrame.frame:Hide()
        return
    end
    -- Hide entirely if not running on Retail
    if not addonTable.Constants.IsRetail then
        if addonTable.MainFrame.frame then addonTable.MainFrame.frame:Hide() end
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
                      professionsConfig.FISHING.enabled

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
                table.insert(addonTable.MainFrame.Counts[category], {itemId, count, itemData})
            end
        end
    end
end

function addonTable.MainFrame.Initialize()
    local header_size = 12
    -- Create the Main panel
    local frame = CreateFrame("frame", "GatherOverview_MainFrame", UIParent, "BackdropTemplate")
    frame:SetPoint("TOP", UIParent, "TOP", 0, -110)
	frame:SetSize(addonTable.Config.Get("width") or 600, addonTable.Config.Get("height") or 800)
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

function addonTable.MainFrame.CreateIcon(parent, itemId, quality)
    local button = CreateFrame("Frame", nil, parent)
    button:SetSize(iconSize, iconSize)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(C_Item.GetItemIconByID(itemId))

    -- Quality
    -- Bronze: |A:Professions-ChatIcon-Quality-Tier1:17:15::1|a
    -- Silver: |A:Professions-ChatIcon-Quality-Tier2:17:23::1|a
    -- Gold: |A:Professions-ChatIcon-Quality-Tier3:17:18::1|a
    if quality ~= 0 then
        local qualityText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        qualityText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        if quality == 1 then
            qualityText:SetText("|A:Professions-ChatIcon-Quality-Tier1:17:15::1|a")
        elseif quality == 2 then
            qualityText:SetText("|A:Professions-ChatIcon-Quality-Tier2:17:23::1|a")
        elseif quality == 3 then
            qualityText:SetText("|A:Professions-ChatIcon-Quality-Tier3:17:18::1|a")
        end
    end

    local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOP", button, "BOTTOM", 0, -5)
    
    button.icon = icon
    button.text = text

    return button
end

local function GetSortedProfessions()
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

    local professionSeting = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
        
    -- Collect enabled and learned categories
    local enabledCategories = {}
    for category, _ in pairs(addonTable.MainFrame.Counts) do
        local professionTranslation = addonTable.ProfessionTranslate[category]
        local display = false
        for _, prof in pairs(professionSeting) do
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

function addonTable.MainFrame.UpdateUI()
    if not addonTable.MainFrame.frame then
        addonTable.MainFrame.Initialize()
    end
    -- If not retail, hide and skip drawing
    if not addonTable.Constants.IsRetail then
        addonTable.MainFrame.frame:Hide()
        return
    end
    local inInstance, _ = IsInInstance()
    if inInstance and addonTable.Config.Get("ShowInInstances") == false then
        addonTable.MainFrame.frame:Hide()
        return
    end
    
    local enabledCategories = GetSortedProfessions()
    
    -- Assign positions: first two in row 0 (col 0 and 1), Fishing in row 1 col 0
    local positions = {}
    local topRow = {}
    for _, category in ipairs(enabledCategories) do
        if category == "FISHING" then
            positions[category] = {col = 0, row = 1}
        elseif #topRow < 2 then
            table.insert(topRow, category)
        end
    end
    -- Assign top row positions
    for i, category in ipairs(topRow) do
        positions[category] = {col = i-1, row = 0}
    end
    
    -- Now position the categories
    local rowIconY = 0
    for category, items in pairs(addonTable.MainFrame.Counts) do
        local professionTranslation = addonTable.ProfessionTranslate[category]
        local pos = positions[category]
        if pos then
            local colIcon = 0

            local x = 10 + pos.col * (sectionWidth + sectionXSpacing)
            local y = -35 - pos.row * (headerHeight - rowIconY)
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
                addonTable.MainFrame.headers[category]:Show()
            end
            for _, info in ipairs(items) do
                local itemID = info[1]
                local count = info[2]
                local item = info[3]
                if C_Item.GetItemInfo(itemID) then
                    if not addonTable.MainFrame.icons[itemID] then
                        addonTable.MainFrame.icons[itemID] = addonTable.MainFrame.CreateIcon(addonTable.MainFrame.frame, itemID, item.quality)
                    end
                    local iconX = x + colIcon * (iconSize + iconSpacingX)
                    addonTable.MainFrame.icons[itemID]:SetPoint("TOPLEFT", addonTable.MainFrame.frame, "TOPLEFT", iconX, rowIconY)
                    addonTable.MainFrame.icons[itemID]:Show()
                    addonTable.MainFrame.icons[itemID].text:SetText(tostring(count))
                    local colorForProfession = addonTable.Colors.GetColorForValue(professionTranslation, count)
                    addonTable.MainFrame.icons[itemID].text:SetTextColor(colorForProfession.r, colorForProfession.g, colorForProfession.b, colorForProfession.a)
                    colIcon = colIcon + 1
                    if colIcon >= itemsPerRow then
                        colIcon = 0
                        rowIconY = rowIconY - (iconSize + 20)
                    end
                end
            end
        else
            -- Hide header if exists
            if addonTable.MainFrame.headers[category] then
                addonTable.MainFrame.headers[category]:Hide()
            end
            -- Hide icons for this category
            for _, info in ipairs(items) do
                local itemID = info[1]
                if addonTable.MainFrame.icons[itemID] then
                    addonTable.MainFrame.icons[itemID]:Hide()
                end
            end
        end
    end
end
