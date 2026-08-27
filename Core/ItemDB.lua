---@class addonTableGatherOverview
local addonTable = select(2, ...)

local L = addonTable.Locales

addonTable.ProfessionTranslate = {
    MINING = L.MINING,
    HERBALISM = L.HERBALISM,
    SKINNING = L.SKINNING,
    FISHING = L.FISHING,
    OTHER_STUFF = L.OTHER_STUFF
}

-- Expansion
local TWW     = addonTable.Constants.EXT_TWW
local MN      = addonTable.Constants.EXT_MN

-- profession
local Mining         = addonTable.Constants.MINING
local Blacksmith     = addonTable.Constants.BLACKSMITH
local Herbalism      = addonTable.Constants.HERBALISM
local Alchemy        = addonTable.Constants.ALCHEMY
local Skinning       = addonTable.Constants.SKINNING
local Leatherworking = addonTable.Constants.LEATHERWORKING
local Enchanting     = addonTable.Constants.ENCHANTING
local Engineering    = addonTable.Constants.ENGiNEERING
local Tailoring      = addonTable.Constants.TAILORING
local Inscription    = addonTable.Constants.INCRIPTION
local Jewelcrafting  = addonTable.Constants.JEWALCRAFTING
local Fishing        = addonTable.Constants.FISHING
local Other          = addonTable.Constants.OTHER_STUFF

addonTable.Profession = {
    {id = Mining, name = L.MINING},
    {id = Blacksmith, name = L.BLACKSMITH},
    {id = Herbalism, name = L.HERBALISM},
    {id = Alchemy, name = L.ALCHEMY},
    {id = Skinning, name = L.SKINNING},
    {id = Leatherworking, name = L.LEATHERWORKING},
    {id = Enchanting, name = L.ENCHANT},
    {id = Engineering, name = L.ENGINEER},
    {id = Tailoring, name = L.TAILORING},
    {id = Inscription, name = L.INSCRIPTION},
    {id = Jewelcrafting, name = L.JEWELCRAFTING},
    {id = Fishing, name = L.FISHING},
    {id = Other, name = L.OTHER_STUFF},
}

addonTable.ItemDB = {
    MINING = {
        -- The War Within
        {id = 210930, extension=TWW,profession=Mining}, -- Bismuth Ore 1 star
        {id = 210931, extension=TWW,profession=Mining}, -- Bismuth Ore 2 star
        {id = 210932, extension=TWW,profession=Mining}, -- Bismuth Ore 3 star
        {id = 210936, extension=TWW,profession=Mining}, -- Ironclaw Ore 1 star
        {id = 210937, extension=TWW,profession=Mining}, -- Ironclaw Ore 2 star
        {id = 210938, extension=TWW,profession=Mining}, -- Ironclaw Ore 3 star
        {id = 210933, extension=TWW,profession=Mining}, -- Aquirite Ore 1 star
        {id = 210934, extension=TWW,profession=Mining}, -- Aquirite Ore 2 star  
        {id = 210935, extension=TWW,profession=Mining}, -- Aquirite Ore 3 star
        {id = 238201, extension=TWW,profession=Mining}, -- Desolate Talus 1 star
        {id = 238212, extension=TWW,profession=Mining}, -- Desolate Talus 2 star
        {id = 238213, extension=TWW,profession=Mining}, -- Desolate Talus 3 star
        {id = 240216, extension=TWW,profession=Mining}, --K'areshi Resonating Stone
        -- Midnight
        {id = 237359, extension=MN,profession=Mining}, -- Refulgent Copper Ore 1 star
        {id = 237361, extension=MN,profession=Mining}, -- Refulgent Copper Ore 2 star
        {id = 237362, extension=MN,profession=Mining}, -- Umbral Tin Ore 1 star
        {id = 237363, extension=MN,profession=Mining}, -- Umbral Tin Ore 2 star
        {id = 237364, extension=MN,profession=Mining}, -- Brilliant Silver Ore 1 star
        {id = 237365, extension=MN,profession=Mining}, -- Brilliant Silver Ore 2 star
        {id = 237366, extension=MN,profession=Mining}, -- Dazzling Thorium
    },
    HERBALISM = {
        -- The War Within
        {id = 210796, extension=TWW,profession=Herbalism}, -- Mycobloom 1 star
        {id = 210797, extension=TWW,profession=Herbalism}, -- Mycobloom 2 star
        {id = 210798, extension=TWW,profession=Herbalism}, -- Mycobloom 3 star
        {id = 210808, extension=TWW,profession=Herbalism}, -- Arathor's Spear 1 star
        {id = 210809, extension=TWW,profession=Herbalism}, -- Arathor's Spear 2 star
        {id = 210810, extension=TWW,profession=Herbalism}, -- Arathor's Spear 3 star
        {id = 210799, extension=TWW,profession=Herbalism}, -- Luredrop 1 star
        {id = 210800, extension=TWW,profession=Herbalism}, -- Luredrop 2 star
        {id = 210801, extension=TWW,profession=Herbalism}, -- Luredrop 3 star
        {id = 210802, extension=TWW,profession=Herbalism}, -- Orbinid 1 star
        {id = 210803, extension=TWW,profession=Herbalism}, -- Orbinid 2 star
        {id = 210804, extension=TWW,profession=Herbalism}, -- Orbinid 3 star
        {id = 210805, extension=TWW,profession=Herbalism}, -- Blessing Blossom 1 star
        {id = 210806, extension=TWW,profession=Herbalism}, -- Blessing Blossom 2 star
        {id = 210807, extension=TWW,profession=Herbalism}, -- Blessing Blossom 3 star
        {id = 239690, extension=TWW,profession=Herbalism}, -- Ghost Flower 1 star
        {id = 239691, extension=TWW,profession=Herbalism}, -- Ghost Flower 2 star
        {id = 239692, extension=TWW,profession=Herbalism}, -- Ghost Flower 3 star
        {id = 240194, extension=TWW,profession=Herbalism}, -- K'areshi Lotus
        -- Midnight
        {id = 236774, extension=MN,profession=Herbalism}, -- Azeroot Rose 1 star
        {id = 236775, extension=MN,profession=Herbalism}, -- Azeroot Rose 2 star
        {id = 236761, extension=MN,profession=Herbalism}, -- Tranquility Bloom 1 star
        {id = 236767, extension=MN,profession=Herbalism}, -- Tranquility Bloom 2 star
        {id = 236770, extension=MN,profession=Herbalism}, -- Sanguithorn 1 star
        {id = 236771, extension=MN,profession=Herbalism}, -- Sanguithorn 2 star
        {id = 236776, extension=MN,profession=Herbalism}, -- Argentleaf 1 star
        {id = 236777, extension=MN,profession=Herbalism}, -- Argentleaf 2 star
        {id = 236778, extension=MN,profession=Herbalism}, -- Mana Lily 1 star
        {id = 236779, extension=MN,profession=Herbalism}, -- Mana Lily 2 star
        {id = 236780, extension=MN,profession=Herbalism}, -- nocturnal-lotus
    },
    SKINNING = {
        -- The War Within
        {id = 212670, extension=TWW,profession=Skinning}, -- Thunderous Hide 1 star
        {id = 212672, extension=TWW,profession=Skinning}, -- Thunderous Hide 2 star
        {id = 212673, extension=TWW,profession=Skinning}, -- Thunderous Hide 3 star
        {id = 212664, extension=TWW,profession=Skinning}, -- Stormvcharge Leather 1 star
        {id = 212665, extension=TWW,profession=Skinning}, -- Stormvcharge Leather 2 star 
        {id = 212666, extension=TWW,profession=Skinning}, -- Stormvcharge Leather 3 star
        {id = 212667, extension=TWW,profession=Skinning}, -- Gloom chitin 1 star
        {id = 212668, extension=TWW,profession=Skinning}, -- Gloom chitin 2 star
        {id = 212669, extension=TWW,profession=Skinning}, -- Gloom chitin 3 star
        {id = 212674, extension=TWW,profession=Skinning}, -- Sunless Carapace 1 star
        {id = 212675, extension=TWW,profession=Skinning}, -- Sunless Carapace 2 star
        {id = 212676, extension=TWW,profession=Skinning}, -- Sunless Carapace 3 star
        -- Midnight
        {id = 238511, extension=MN,profession=Skinning}, -- Void-Tempered Leather 1 star
        {id = 238512, extension=MN,profession=Skinning}, -- Void-Tempered Leather 2 star
        {id = 238513, extension=MN,profession=Skinning}, -- Void-Tempered Scales 1 star
        {id = 238514, extension=MN,profession=Skinning}, -- Void-Tempered Scales 2 star
        {id = 238520, extension=MN,profession=Skinning}, -- Void-Tempered Plating 1 star
        {id = 238521, extension=MN,profession=Skinning}, -- Void-Tempered Plating 2 star
        {id = 238518, extension=MN,profession=Skinning}, -- Void-Tempered Hide 1 star
        {id = 238519, extension=MN,profession=Skinning}, -- Void-Tempered Hide 2 star
        {id = 238523, extension=MN,profession=Skinning}, -- Carving Canine
        {id = 238522, extension=MN,profession=Skinning}, -- Peerless Plumage
        {id = 238525, extension=MN,profession=Skinning}, -- Fantastic Fur
        {id = 238529, extension=MN,profession=Skinning}, -- Majestic Hide
        {id = 238530, extension=MN,profession=Skinning}, -- Majestic Fin
    },
    FISHING = {
        -- The War Within
        {id = 220134, extension=TWW,profession=Fishing}, -- Dilly-Dilly Dace
        {id = 220135, extension=TWW,profession=Fishing}, -- Bloody Perch
        {id = 220136, extension=TWW,profession=Fishing}, -- Crystalline Sturgeon
        {id = 220137, extension=TWW,profession=Fishing}, -- Bismuth Bitterling
        {id = 220138, extension=TWW,profession=Fishing}, -- Nibbling Minnow
        {id = 220139, extension=TWW,profession=Fishing}, -- Whispering Stargazer
        {id = 220141, extension=TWW,profession=Fishing}, -- Specular Rainbowfish
        {id = 220142, extension=TWW,profession=Fishing}, -- Quiet River Bass
        {id = 220143, extension=TWW,profession=Fishing}, -- Dornish Pike
        {id = 220144, extension=TWW,profession=Fishing}, -- Roaring Anglerseeker
        {id = 220145, extension=TWW,profession=Fishing}, -- Arathor Hammerfish
        {id = 220146, extension=TWW,profession=Fishing}, -- Regal Dottyback
        {id = 220147, extension=TWW,profession=Fishing}, -- Kaheti Slum Shark
        {id = 220148, extension=TWW,profession=Fishing}, -- Pale Huskfish
        {id = 220149, extension=TWW,profession=Fishing}, -- Sanguine Dogfish
        {id = 220150, extension=TWW,profession=Fishing}, -- Spiked Sea Raven
        {id = 220151, extension=TWW,profession=Fishing}, -- Queen's Lurefish
        {id = 220152, extension=TWW,profession=Fishing}, -- Cursed Ghoulfish
        {id = 220153, extension=TWW,profession=Fishing}, -- Awoken Coelacanth
        {id = 222533, extension=TWW,profession=Fishing}, -- Goldendill Trout
        {id = 227673, extension=TWW,profession=Fishing}, -- "Gold" Fish
        -- Midnight
        {id = 238365, extension=MN,profession=Fishing}, -- Sin'dorei Swarmer
        {id = 238366, extension=MN,profession=Fishing}, -- Lynxfish
        {id = 238367, extension=MN,profession=Fishing}, -- Root Crab
        {id = 238368, extension=MN,profession=Fishing}, -- Twisted Tetra
        {id = 238369, extension=MN,profession=Fishing}, -- Bloomtail Minnow
        {id = 238370, extension=MN,profession=Fishing}, -- Shimmer Spinefish
        {id = 238371, extension=MN,profession=Fishing}, -- Arcane Wyrmfish
        {id = 238372, extension=MN,profession=Fishing}, -- Restored Songfish
        {id = 238373, extension=MN,profession=Fishing}, -- Ominous Octopus
        {id = 238374, extension=MN,profession=Fishing}, -- Tender Lumifin
        {id = 238375, extension=MN,profession=Fishing}, -- Fungalskin Pike
        {id = 238376, extension=MN,profession=Fishing}, -- Lucky Loa
        {id = 238378, extension=MN,profession=Fishing}, -- Shimmersiren
        {id = 238379, extension=MN,profession=Fishing}, -- Warping Wise
        {id = 238380, extension=MN,profession=Fishing}, -- Null Voidfish
        {id = 238381, extension=MN,profession=Fishing}, -- Hollow Grouper
        {id = 238382, extension=MN,profession=Fishing}, -- Gore Guppy
        {id = 238383, extension=MN,profession=Fishing}, -- Eversong Trout
        {id = 238384, extension=MN,profession=Fishing}, -- Sunwell Fish
        {id = 274592, extension=MN,profession=Fishing}, -- Dirty Darter
        {id = 274588, extension=MN,profession=Fishing}, -- Toxic Tlhapi
        {id = 279094, extension=MN,profession=Fishing}, -- Grotesque Sturgeon
        {id = 274591, extension=MN,profession=Fishing}, -- Coiled Stargorger
        {id = 274589, extension=MN,profession=Fishing}, -- Ula'tek Snakehead
        {id = 279106, extension=MN,profession=Fishing}, -- Loathsome Anglerfish
        {id = 274593, extension=MN,profession=Fishing}, -- Blightswarmer
        {id = 274590, extension=MN,profession=Fishing}, -- Sulfurous Sludgefish
        {id = 279100, extension=MN,profession=Fishing}, -- Many-Eyed Flounder
        {id = 279105, extension=MN,profession=Fishing}, -- Twin-Headed Snipefish
        {id = 274594, extension=MN,profession=Fishing}, -- Polluted Puffer
        {id = 279091, extension=MN,profession=Fishing}, -- Oozing Goby
    },
    OTHER_STUFF = {
        -- mote
        {id = 236950, extension=MN,profession=Other}, -- Mote of Primal Energy
        {id = 236952, extension=MN,profession=Other}, -- Mote of Pure Void
        {id = 236951, extension=MN,profession=Other}, -- Mote of Wild Magic
        {id = 236949, extension=MN,profession=Other}, -- Mote of Light

        -- 12.1 particules
        {id = 274781, extension=MN,profession=Other}, -- Cursebound Globe
        {id = 274777, extension=MN,profession=Other}, -- Neutralized Venom Clot

        -- weekly points
        -- CatchUp curency Id are hidden
        -- see : https://www.wowhead.com/search?q=professions+tracker+weekly#currencies
        -- Other weekly are obtained by completing hidden quests
        {id = 259188, extension=MN,profession=Alchemy, questId = { 93528 }}, -- Lightbloomed Spore Sample
        {id = 259189, extension=MN,profession=Alchemy, questId = { 93529 }}, -- Aged Cruor
        {id = 259190, extension=MN,profession=Blacksmith, questId = { 93530 }, kp = 2}, -- Thalassian Whestone
        {id = 259191, extension=MN,profession=Blacksmith, questId = { 93531 }, kp = 2}, -- Infused Quenching Oil
        {id = 259192, extension=MN,profession=Enchanting, questId = { 93532 }, kp = 2}, -- Voidstorm Ashes
        {id = 259193, extension=MN,profession=Enchanting, questId = { 93533 }, kp = 2}, -- Lost Thalassian Vellum
        {id = 259193, extension=MN,profession=Enchanting, currencyId = 3198, countDependency = {259193, 259192}}, -- Shimmering Dust Catch up mechanic
        {id = 259194, extension=MN,profession=Engineering, questId = { 93534 }}, -- Dance Gear
        {id = 259195, extension=MN,profession=Engineering, questId = { 93535 }}, -- Dawn Capacitor
        {id = 238465, extension=MN,profession=Herbalism, questId = { 81425, 81426, 81427, 81428, 81429 }}, -- Thalassian Phoenix Plume
        {id = 238466, extension=MN,profession=Herbalism, questId = { 81430 }, kp = 4}, -- Thalassian Phoenix Tail
        {id = 238467, extension=MN,profession=Herbalism, currencyId = 3196, countDependency = {238466, 238465}}, -- Thalassian Phoenix Ember catchup
        {id = 259196, extension=MN,profession=Inscription, questId = { 93536 }, kp = 2}, -- Brilliant Phoenix Ink
        {id = 259197, extension=MN,profession=Inscription, questId = { 93537 }, kp = 2}, -- Loa-Blessed Rune
        {id = 259199, extension=MN,profession=Jewelcrafting, questId = { 93539 }, kp = 2}, -- Harandar Stone Sample
        {id = 259198, extension=MN,profession=Jewelcrafting, questId = { 93538 }, kp = 2}, -- Void-Touched Eversong Diamond Fragments
        {id = 259200, extension=MN,profession=Leatherworking, questId = { 93540 }, kp = 2}, -- Amani Tanning Oil
        {id = 259201, extension=MN,profession=Leatherworking, questId = { 93541 }, kp = 2}, -- Thalassian Mana Oil
        {id = 237496, extension=MN,profession=Mining, questId = { 88673, 88674, 88675, 88676, 88677 }}, -- Igneous Rock Specimen
        {id = 237506, extension=MN,profession=Mining, questId = { 88678 }, kp = 3}, -- Septarian Nodule
        {id = 237507, extension=MN,profession=Mining, currencyId = 3192, countDependency = {237506, 237496}}, -- Cloudy Quartz Catch up mechanic
        {id = 238625, extension=MN,profession=Skinning, questId = { 88534, 88549, 88536, 88537, 88530 }}, -- Fine Void-Tempered Hide
        {id = 238626, extension=MN,profession=Skinning, questId = { 88529 }, kp = 3}, -- Mana-Infused Bone
        {id = 238627, extension=MN,profession=Skinning, currencyId = 3191, countDependency = {238626, 238625}}, -- Manafused Sample Catch up mechanic
        {id = 259202, extension=MN,profession=Tailoring, questId = { 93542 }, kp = 2}, -- Embroidered Memento
        {id = 259203, extension=MN,profession=Tailoring, questId = { 93543 }, kp = 2}, -- Finely Woven Lynx Collar
    },
}

---Initialise les instances Item depuis la base de données
function addonTable.InitializeItems()
    local Item = addonTable.Components.Item
    local items = {}
    local allItems = {}

    for profession, itemList in pairs(addonTable.ItemDB) do
        items[profession] = {}

        for _, itemData in ipairs(itemList) do
            local item = Item:new(itemData.id, itemData.extension, itemData.profession, itemData.kp)
            table.insert(items[profession], item)
            table.insert(allItems, item)
            if itemData.currencyId then
                item:setCurrencyId(itemData.currencyId)
            end
            if itemData.questId then
                for _, qId in ipairs(itemData.questId) do
                    item:addQuestId(qId)
                end
            end
            if itemData.countDependency then
                for _, cId in ipairs(itemData.countDependency) do
                    for _,it in pairs(allItems) do
                        if it.id == cId then
                            item:addCountDependency(it)
                        end
                    end
                end
            end
            
        end
    end
    wipe(allItems)
    addonTable.Items = items
    return items
end