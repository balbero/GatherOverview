---@class addonTableGatherOverview
local addonTable = select(2, ...)

---@class Item
---@field id number L'ID de l'item dans la base de données WoW
---@field extension number L'extension auquel appartient cet item
---@field name string Le nom de l'item
---@field icon string L'icône de l'item
---@field questId table Les IDs des quêtes associées
---@field currencyId number L'ID de la monnaie associée
---@field dependency table Les IDs des items dont dépend le comptage des points restant
---@field profession number La profession associée (MINING, HERBALISM, etc.)
---@field count number Le nombre d'items actuellement dans le sac
---@field total number Le nombre d'items actuellement en possession (sac + banques)
---@field kp number Le nombre de point de connaissance de l'Item
local Item = {}
Item.__index = Item
addonTable.Components.Item = Item


local L = addonTable.Locales

local function GetFont()
    return addonTable.Config.Get(addonTable.Config.Options.FONT)
end

local function GetFontSize()
    return addonTable.Config.Get(addonTable.Config.Options.FONT_SIZE)
end

---Crée une nouvelle instance d'Item
---@param id number L'ID de l'item
---@param extension number L'extension de l'item
---@param profession number La profession associée
---@param kp number les points de connaissance associé à l'item
---@return Item
function Item:new(id, extension, profession, kp)
    local instance = setmetatable({}, self)

    instance.id = id
    instance.extension = extension
    instance.profession = profession
    instance.questId = {}
    instance.currencyId = nil
    instance.dependency = {}
    instance.count = 0
    instance.total = 0
    instance.kp = kp or 1

    -- Charger les informations de l'item depuis WoW
    instance:_loadItemInfo()

    return instance
end

---Charge les informations de l'item depuis la base de données WoW
function Item:_loadItemInfo()
    self.name = C_Item.GetItemInfo(self.id) or ""
    self.icon = C_Item.GetItemIconByID(self.id) or ""
    self.count = C_Item.GetItemCount(self.id) or 0
    self.total = C_Item.GetItemCount(self.id, true, nil, true, true) or 0
end

---Ajoute une dependence à un item pour cet Item
---@param item Item
function Item:addCountDependency(item)
    table.insert(self.dependency, item)
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

---Récupère le nombre de quêtes incomplètes
---@return number
function Item:getKnowledgePointRemaining()
    local remainingPoints = 0
    if #self.questId > 0 then
        remainingPoints = self:getMissingQuestCount()
    end
    if self.currencyId then
        local currencyInfo = self:getCurrencyInfo()
        remainingPoints = (currencyInfo and currencyInfo.max or 0) - (currencyInfo and currencyInfo.quantity or 0)
    end
    return remainingPoints * self.kp
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

---Récupère le nombre total d'objet si l'Item a soit une currency ou des questId
---@return number
function Item:getTotalToCatch()
    local totalToCatch = -1
    if self.currencyId then
        local currencyInfo = self:getCurrencyInfo()
        totalToCatch = (currencyInfo and currencyInfo.max or 0) - (currencyInfo and currencyInfo.quantity or 0)
    end
    if #self.questId > 0 then
        totalToCatch = self:getMissingQuestCount()
    end

    if #self.dependency > 0 then
        for _,dep in pairs(self.dependency) do
            totalToCatch = totalToCatch - dep:getKnowledgePointRemaining()
        end
    end

    return totalToCatch
end

---Formate le count pour l'affichage (ex: 1250 -> "1.2K+")
---@return string
function Item:getFormattedCount()
    local showTotal = addonTable.Config.Get(addonTable.Config.Options.SHOW_TOTAL)
    local count = showTotal and self.total or self.count

    local totalToCatch = self:getTotalToCatch()
    
    if totalToCatch ~= -1 then
        count = totalToCatch
    end

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

---Retourne le message affiché dans le tooltip
---@return string
function Item:getDisplayToolTipMessage()
    local message = L.IN_BAGS .. ": " .. self.count .. "\n" .. L.IN_BANK .. ": " .. (self.total - self.count) .. "\n" .. L.TOTAL .. ": " .. self.total

    local totalToCatch = self:getTotalToCatch()
    if totalToCatch ~= -1 then
        message = L.STILL_TO_GET .. ": " .. totalToCatch
    end
    return message
end

---Crée un widget d'affichage pour cet item (frame WoW natif)
---@param parent Frame? Parent frame optionnel
---@return Frame
function Item:createWidget(parent)
    local button = CreateFrame("Button", nil, parent or UIParent)

    -- Icône de l'item
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(self.icon)
    button.icon = icon


    local itemInfo = C_TradeSkillUI.GetItemReagentQualityInfo(self.id)
    if itemInfo and itemInfo.icon then
        -- Qualité de l'item (small icon en haut à gauche)
        local qualityText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        qualityText:SetPoint("TOPLEFT", button, "TOPLEFT", -7, 7)
        local text = "|A:"..itemInfo.icon..":20:20|a"
        qualityText:SetText(text)
    end

    -- Nombre d'items
    local countText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    countText:SetPoint("TOP", button, "BOTTOM", 0, -5)
    countText:SetFont(GetFont().path, GetFontSize(), "OUTLINE")
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
            GameTooltip:AddLine(self.item:getDisplayToolTipMessage(), 1, 1, 1, true)
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
    widget.countText:SetFont(GetFont().path, GetFontSize(), "OUTLINE")
    widget.countText:SetText(self:getFormattedCount())
    self:updateToolTip(widget)
end

---Compare deux items
---@param other Item
---@return boolean
function Item:equals(other)
    return self.id == other.id and self.extension == other.extension
end

