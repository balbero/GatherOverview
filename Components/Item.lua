---@class addonTableGatherOverview
local addonTable = select(2, ...)

local L = addonTable.Locales

local function GetFont()
    return addonTable.Config.Get(addonTable.Config.Options.FONTS)
end

---@class Item
---@field id number L'ID de l'item dans la base de données WoW
---@field extension number L'extension auquel appartient cet item
---@field name string Le nom de l'item
---@field icon string L'icône de l'item
---@field questId table Les IDs des quêtes associées
---@field currencyId number L'ID de la monnaie associée
---@field profession string La profession associée (MINING, HERBALISM, etc.)
---@field count number Le nombre d'items actuellement dans le sac
---@field total number Le nombre d'items actuellement en possession (sac + banques)
local Item = {}
Item.__index = Item

---Crée une nouvelle instance d'Item
---@param id number L'ID de l'item
---@param extension number L'extension de l'item
---@param profession string La profession associée
---@return Item
function Item:new(id, extension, profession)
    local self = setmetatable({}, Item)

    self.id = id
    self.extension = extension
    self.profession = profession
    self.questId = {}
    self.currencyId = nil
    self.count = 0
    self.total = 0

    -- Charger les informations de l'item depuis WoW
    self:_loadItemInfo()

    return self
end

---Charge les informations de l'item depuis la base de données WoW
function Item:_loadItemInfo()
    self.name = C_Item.GetItemInfo(self.id) or ""
    self.icon = C_Item.GetItemIconByID(self.id) or ""
    self.count = C_Item.GetItemCount(self.id) or 0
    self.total = C_Item.GetItemCount(self.id, true, nil, true, true) or 0
end

---Ajoute une quête associée à cet item
---@param quest_id number
function Item:addQuestId(quest_id)
    table.insert(self.questId, quest_id)
end

---Défini la monnaie associée à cet item
---@param currencyId number
function Item:setCurrencyId(currencyId)
    self.currencyId = currencyId
end

---Récupère le nombre de quêtes incomplètes
---@return number
function Item:getMissingQuestCount()
    local ret = #self.questId
    for _, id in ipairs(self.questId) do
        if C_QuestLog.IsQuestFlaggedCompleted(id) then
            ret = ret - 1
        end
    end
    return ret
end

---Récupère les informations de monnaie actualisées
---@return table|nil
function Item:getCurrencyInfo()
    if not self.currencyId then
        return nil
    end

    local info = C_CurrencyInfo.GetCurrencyInfo(self.currencyId)
    if not info then
        return nil
    end

    return {
        quantity = info.quantity,
        max = info.maxQuantity,
        weeklyEarned = info.quantityEarnedThisWeek,
        maxWeeklyEarned = info.maxWeeklyQuantity,
        totalEarned = info.totalEarned,
    }
end

---Formate le count pour l'affichage (ex: 1250 -> "1.2K+")
---@return string
function Item:getFormattedCount()
    local count = self.count
    if count > 999 then
        return math.floor(count / 1000) .. "K+"
    end
    return tostring(count)
end

---Retourne le nom affiché avec la qualité si disponible
---@return string
function Item:getDisplayName()
    return self.name or ""
end

---Retourne un résumé complet de l'item
---@return string
function Item:getSummary()
    local summary = string.format(
        "Item: %s (ID: %d)\nProfession: %s\nExtension: %d\nCount: %d",
        self.name,
        self.id,
        self.profession,
        self.extension,
        self.count
    )

    if #self.questId > 0 then
        summary = summary .. string.format("\nQuêtes associées: %d", #self.questId)
    end

    if self.currencyId then
        summary = summary .. string.format("\nMonnaie ID: %d", self.currencyId)
    end

    return summary
end

---Crée un widget d'affichage pour cet item (frame WoW natif)
---@param parent Frame? Parent frame optionnel
---@return Frame
function Item:createWidget(parent)
    local button = CreateFrame("Button", nil, parent or UIParent)
    local profession = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    local icon_width = profession[self.profession].icon_width
    local icon_height = profession[self.profession].icon_height
    button:SetSize(icon_width, icon_height)

    -- Icône de l'item
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(self.icon)
    button.icon = icon

    -- Qualité de l'item (small icon en haut à gauche)
    local qualityText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    qualityText:SetPoint("TOPLEFT", button, "TOPLEFT", -7, 7)
    qualityText:SetFont(GetFont(), 10, "OUTLINE")

    local itemInfo = C_TradeSkillUI.GetItemReagentQualityInfo(self.id)
    if itemInfo and itemInfo.icon then
        local text = "|A:"..itemInfo.icon..":20:20|a"
        qualityText:SetText(text)
    end
    button.qualityText = qualityText

    -- Nombre d'items
    local countText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    countText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, 2)
    countText:SetFont(GetFont(), 10, "OUTLINE")
    countText:SetText(self:getFormattedCount())
    button.countText = countText

    -- Stocker la référence à l'item
    button.item = self

    return button
end

function Item:updateToolTip(widget)
    if not widget then
        return
    end

    widget:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.item.name, 1, .82, 0, true)
            GameTooltip:AddLine(L.IN_BAGS .. self.item.count, 1, 1, 1, true)
            GameTooltip:AddLine(L.IN_BANK .. (self.item.total - self.item.count), 1, 1, 1, true)
            GameTooltip:AddLine(L.TOTAL .. self.item.total, 1, 1, 1, true)
            GameTooltip:Show()
    end)

    widget:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end 

---Met à jour l'affichage du widget
---@param widget Frame
function Item:updateWidget(widget)
    if not widget or not widget.countText then
        return
    end
    widget.countText:SetText(self:getFormattedCount())
    self.updateToolTip(widget)
end

---Compare deux items
---@param other Item
---@return boolean
function Item:equals(other)
    return self.id == other.id and self.extension == other.extension
end

addonTable.Components.Item = Item
