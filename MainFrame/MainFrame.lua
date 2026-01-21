---@class addonTableGatherOverview
local addonTable = select(2, ...)
local AceGUI = LibStub("AceGUI-3.0")

addonTable.MainFrame = {}
addonTable.MainFrame.labels = {}
addonTable.MainFrame.Counts = {}

local itemsPerRow = 3  -- Nombre d'icônes par ligne
local iconSize = 32    -- Taille des icônes
local itemWidth = 50   -- Largeur par item (icône + label)
local headerHeight = 20
local iconSpacingX = 10
local iconSpacingY = 10

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

    
    local currentY = -10

    local professionSeting = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    for category, itemData in pairs(addonTable.MainFrame.Counts) do
        local professionTranslation = addonTable.ProfessionTranslate[category]
        local display = false
        -- Check if the category (i.E the profession) is enabled in the curent profile
        for _, prof in pairs(professionSeting) do
            if professionTranslation == prof.name then
                display = prof.enabled
                break
            end
        end
        if display then
             -- Create header if not exists
            if not addonTable.MainFrame.headers[category] then
                local header = addonTable.MainFrame.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                header:SetPoint("TOPLEFT", addonTable.MainFrame.frame, "TOPLEFT", 10, currentY)
                header:SetText(professionTranslation)
                addonTable.MainFrame.headers[category] = header
            else
                addonTable.MainFrame.headers[category]:SetPoint("TOPLEFT", addonTable.MainFrame.frame, "TOPLEFT", 10, currentY)
                addonTable.MainFrame.headers[category]:Show()
            end
            currentY = currentY - headerHeight
            local rowY = currentY
            local col = 0

            for _, info in ipairs(itemData) do
                -- info[1] => item id
                -- info[2] => cont in bags
                -- info[3] => item contains quality and extension
                if C_Item.GetItemInfo(info[1]) then
                    if not addonTable.MainFrame.icons[info[1]] then
                        addonTable.MainFrame.icons[info[1]] = addonTable.MainFrame.CreateIcon(addonTable.MainFrame.frame, info[1], info[3].quality)
                    end
                    local x = 10 + col * (iconSize + iconSpacingX)
                    addonTable.MainFrame.icons[info[1]]:SetPoint("TOPLEFT", addonTable.MainFrame.frame, "TOPLEFT", x, rowY)
                    addonTable.MainFrame.icons[info[1]]:Show()
                    addonTable.MainFrame.icons[info[1]].text:SetText(info[2])
                    local colorForProfession = addonTable.Colors.GetColorForValue(professionTranslation, info[2])
                    addonTable.MainFrame.icons[info[1]].text:SetTextColor(colorForProfession.r, colorForProfession.g, colorForProfession.b, colorForProfession.a)
                    col = col + 1
                    if col >= itemsPerRow then
                        col = 0
                        rowY = rowY - (iconSize + 20)  -- Approximate height for icon + text
                    end
                end
            end
            -- Update currentY for next category
            if col > 0 then
                currentY = rowY - (iconSize + 20)
            else
                currentY = rowY
            end
        else
            -- Hide header if exists
            if addonTable.MainFrame.headers[category] then
                addonTable.MainFrame.headers[category]:Hide()
            end
            -- Hide icons for this category
            for _, info in pairs(itemData) do
                if addonTable.MainFrame.icons[info[1]] then
                    addonTable.MainFrame.icons[info[1]]:Hide()
                end
            end
        end
    end
end
