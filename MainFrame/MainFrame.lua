---@class addonTableGatherOverview
local addonTable = select(2, ...)
local AceGUI = LibStub("AceGUI-3.0")

addonTable.MainFrame = {}
addonTable.MainFrame.labels = {}

local itemsPerRow = 3  -- Nombre d'icônes par ligne
local iconSize = 32    -- Taille des icônes
local itemWidth = 50   -- Largeur par item (icône + label)

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

function addonTable.MainFrame.Initialize()
    -- Créer le frame principal
    local frame = AceGUI:Create("Frame")
    frame:SetLayout("List")  -- Changé de "Fill" à "List" pour empiler plusieurs enfants verticalement
    frame:SetWidth(600)  -- Largeur fixe plus grande pour accommoder deux professions côte à côte
    
    frame.frame:SetFrameStrata("LOW")  -- Réduire le z-level pour que la frame soit derrière d'autres éléments UI

    -- Configurer l'arrière-plan sans bordure, avec opacité de BG_ALPHA
    local alpha = addonTable.Config.Get("BackgroundAlpha")
    frame.frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = nil,  -- Pas de bordure
        tile = true,
        tileSize = 0,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame.frame:SetBackdropColor(0, 0, 0, 1-alpha)  -- Arrière-plan noir avec alpha
    frame:SetTitle(addonTable.Locales.GATHER_OVERVIEW)

    local professionsConfig = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)

    local showFrame = professionsConfig.MINING.enabled or professionsConfig.HERBALISM.enabled or professionsConfig.SKINNING.enabled or professionsConfig.FISHING.enabled

    local miningHerbsGroup = AceGUI:Create("SimpleGroup")
    miningHerbsGroup:SetLayout("Flow")
    miningHerbsGroup:SetFullWidth(true)  -- Assurer que le groupe prend toute la largeur
    if professionsConfig.MINING.enabled then
        local miningFrame = addonTable.MainFrame.CreateMiningItemsFrame()
        miningHerbsGroup:AddChild(miningFrame)
    end
    if professionsConfig.HERBALISM.enabled then
        local herbalismFrame = addonTable.MainFrame.CreateHerbalismItemsFrame()
        miningHerbsGroup:AddChild(herbalismFrame)
    end
    miningHerbsGroup:DoLayout()
    frame:AddChild(miningHerbsGroup)
    
    local skinningFishGroup = AceGUI:Create("SimpleGroup")
    skinningFishGroup:SetLayout("Flow")
    skinningFishGroup:SetFullWidth(true)  -- Assurer que le groupe prend toute la largeur
    if professionsConfig.SKINNING.enabled then
        local skinningFrame = addonTable.MainFrame.CreateSkinningItemsFrame()
        skinningFishGroup:AddChild(skinningFrame)
    end
    if professionsConfig.FISHING.enabled then
        local fishingFrame = addonTable.MainFrame.CreateFishingItemsFrame()
        skinningFishGroup:AddChild(fishingFrame)
    end
    skinningFishGroup:DoLayout()
    frame:AddChild(skinningFishGroup)
    
    frame:DoLayout()

    addonTable.MainFrame.frame = frame
    if showFrame then
        frame:Show()
    else
        frame:Hide()
    end
end

function addonTable.MainFrame.CreateItemGroup(itemID, professionName)
    local itemGroup = AceGUI:Create("SimpleGroup")
    itemGroup:SetLayout("List")  -- Vertical : icône puis label
    itemGroup:SetWidth(itemWidth)
    itemGroup:SetHeight(iconSize + 15)

    -- Sous-groupe pour centrer l'icône horizontalement
    local iconGroup = AceGUI:Create("SimpleGroup")
    iconGroup:SetLayout("Flow")  -- Horizontal pour les spacers et l'icône
    iconGroup:SetHeight(iconSize + 15)  -- Hauteur réduite
    iconGroup:SetFullWidth(true)

    -- Spacer gauche pour centrer
    local spacerLeft = AceGUI:Create("SimpleGroup")
    spacerLeft:SetWidth(math.floor((itemWidth - iconSize) / 2))
    iconGroup:AddChild(spacerLeft)

    -- Icône de l'item
    local icon = AceGUI:Create("Icon")
    icon:SetImage(C_Item.GetItemIconByID(itemID))  -- Récupère l'icône via l'API WoW
    icon:SetImageSize(iconSize, iconSize)
    iconGroup:AddChild(icon)
    
    -- Spacer droite pour centrer
    local spacerRight = AceGUI:Create("SimpleGroup")
    spacerRight:SetWidth((itemWidth - iconSize) / 2)
    iconGroup:AddChild(spacerRight)

    itemGroup:AddChild(iconGroup)

    -- Label pour le nombre d'objets
    local label = AceGUI:Create("Label")
    local count = C_Item.GetItemCount(itemID)  -- Nombre dans les sacs
    label:SetText(tostring(count))
    label:SetJustifyH("CENTER")  -- Centrer le texte
    label:SetWidth(itemWidth)

    addonTable.MainFrame.labels[itemID] = {label = label, prof = professionName}

    -- Couleur basée sur les seuils du profil courant
    local color = addonTable.Colors.GetColorForValue(professionName, count)
    label:SetColor(color.r, color.g, color.b, color.a)

    itemGroup:AddChild(label)
    return itemGroup
end

-- Fonction pour créer le frame des items de minage
function addonTable.MainFrame.CreateMiningItemsFrame()
    -- Conteneur principal pour la grille
    local mainContainer = AceGUI:Create("SimpleGroup")
    mainContainer:SetLayout("List")  -- Empilement vertical des lignes
    mainContainer:SetFullWidth(true)

    -- Paramètres de la grille
    local rowContainer

    -- Boucle sur les items de MINING
    for i, itemID in ipairs(addonTable.ItemDB.MINING) do
        if C_Item.GetItemInfo(itemID) then
            -- Créer une nouvelle ligne si nécessaire
            if (i - 1) % itemsPerRow == 0 then
                rowContainer = AceGUI:Create("SimpleGroup")
                rowContainer:SetLayout("Flow")  -- Disposition horizontale dans la ligne
                rowContainer:SetFullWidth(true)
                mainContainer:AddChild(rowContainer)
            end

            -- Groupe pour chaque item (icône + label verticalement)
            local itemGroup = addonTable.MainFrame.CreateItemGroup(itemID, addonTable.Locales.MINING)
            -- Ajouter le groupe d'item à la ligne
            rowContainer:AddChild(itemGroup)
        end
    end

    return mainContainer
end

-- Fonction pour créer le frame des items d'herboristerie
function addonTable.MainFrame.CreateHerbalismItemsFrame()
    -- Conteneur principal pour la grille
    local mainContainer = AceGUI:Create("SimpleGroup")
    mainContainer:SetLayout("List")  -- Empilement vertical des lignes
    mainContainer:SetFullWidth(true)

    -- Paramètres de la grille
    local rowContainer

    -- Boucle sur les items de HERBALISM
    for i, itemID in ipairs(addonTable.ItemDB.HERBALISM) do
        if C_Item.GetItemInfo(itemID) then
            -- Créer une nouvelle ligne si nécessaire
            if (i - 1) % itemsPerRow == 0 then
                rowContainer = AceGUI:Create("SimpleGroup")
                rowContainer:SetLayout("Flow")  -- Disposition horizontale dans la ligne
                rowContainer:SetFullWidth(true)
                mainContainer:AddChild(rowContainer)
            end

            local itemGroup = addonTable.MainFrame.CreateItemGroup(itemID, addonTable.Locales.HERBALISM)

            -- Ajouter le groupe d'item à la ligne
            rowContainer:AddChild(itemGroup)
        end
    end

    return mainContainer
end

-- Fonction pour créer le frame des items de dépeçage
function addonTable.MainFrame.CreateSkinningItemsFrame()

    -- Conteneur principal pour la grille
    local mainContainer = AceGUI:Create("SimpleGroup")
    mainContainer:SetLayout("List")  -- Empilement vertical des lignes
    mainContainer:SetFullWidth(true)

    -- Paramètres de la grille
    local rowContainer

    -- Boucle sur les items de SKINNING
    for i, itemID in ipairs(addonTable.ItemDB.SKINNING) do
        if C_Item.GetItemInfo(itemID) then
            -- Créer une nouvelle ligne si nécessaire
            if (i - 1) % itemsPerRow == 0 then
                rowContainer = AceGUI:Create("SimpleGroup")
                rowContainer:SetLayout("Flow")  -- Disposition horizontale dans la ligne
                rowContainer:SetFullWidth(true)
                mainContainer:AddChild(rowContainer)
            end
            local itemGroup = addonTable.MainFrame.CreateItemGroup(itemID, addonTable.Locales.SKINNING)

            -- Ajouter le groupe d'item à la ligne
            rowContainer:AddChild(itemGroup)
        end
    end

    return mainContainer
end

-- Fonction pour créer le frame des items de dépeçage
function addonTable.MainFrame.CreateFishingItemsFrame()
    -- Conteneur principal pour la grille
    local mainContainer = AceGUI:Create("SimpleGroup")
    mainContainer:SetLayout("List")  -- Empilement vertical des lignes
    mainContainer:SetFullWidth(true)

    -- Paramètres de la grille
    local rowContainer

    -- Boucle sur les items de FISHING
    for i, itemID in ipairs(addonTable.ItemDB.FISHING) do
        if C_Item.GetItemInfo(itemID) then
            -- Créer une nouvelle ligne si nécessaire
            if (i - 1) % itemsPerRow == 0 then
                rowContainer = AceGUI:Create("SimpleGroup")
                rowContainer:SetLayout("Flow")  -- Disposition horizontale dans la ligne
                rowContainer:SetFullWidth(true)
                mainContainer:AddChild(rowContainer)
            end

            local itemGroup = addonTable.MainFrame.CreateItemGroup(itemID, addonTable.Locales.FISHING)

            -- Ajouter le groupe d'item à la ligne
            rowContainer:AddChild(itemGroup)
        end
    end
    return mainContainer
end