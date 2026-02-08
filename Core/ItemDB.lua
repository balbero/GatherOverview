---@class addonTableGatherOverview
local addonTable = select(2, ...)

addonTable.ProfessionTranslate = {
    MINING = addonTable.Locales.MINING,
    HERBALISM = addonTable.Locales.HERBALISM,
    SKINNING = addonTable.Locales.SKINNING,
    FISHING = addonTable.Locales.FISHING
}

-- Quality
local NONE      = 0
local ONESTAR   = 1
local TWOSTAR   = 2
local THREESTAR = 3

-- Expansion
local TWW     = 11
local MN      = 12

addonTable.blacklistedZone = {
}

addonTable.ItemDB = {
    MINING = {
        -- The War Within
        {id = 210930, extension=TWW}, -- Bismuth Ore 1 star
        {id = 210931, extension=TWW}, -- Bismuth Ore 2 star
        {id = 210932, extension=TWW}, -- Bismuth Ore 3 star
        {id = 210936, extension=TWW}, -- Ironclaw Ore 1 star
        {id = 210937, extension=TWW}, -- Ironclaw Ore 2 star
        {id = 210938, extension=TWW}, -- Ironclaw Ore 3 star
        {id = 210933, extension=TWW}, -- Aquirite Ore 1 star
        {id = 210934, extension=TWW}, -- Aquirite Ore 2 star  
        {id = 210935, extension=TWW}, -- Aquirite Ore 3 star
        {id = 238201, extension=TWW}, -- Desolate Talus 1 star
        {id = 238212, extension=TWW}, -- Desolate Talus 2 star
        {id = 238213, extension=TWW}, -- Desolate Talus 3 star
        {id = 240216, extension=TWW}, --K'areshi Resonating Stone
        -- Midnight
        {id = 237359, extension=MN}, -- Refulgent Copper Ore 1 star
        {id = 237361, extension=MN}, -- Refulgent Copper Ore 2 star
        {id = 237362, extension=MN}, -- Umbral Tin Ore 1 star
        {id = 237363, extension=MN}, -- Umbral Tin Ore 2 star
        {id = 237364, extension=MN}, -- Brilliant Silver Ore 1 star
        {id = 237365, extension=MN}, -- Brilliant Silver Ore 2 star
        {id = 237366, extension=MN}, -- Dazzling Thorium
    },
    HERBALISM = {
        -- The War Within
        {id = 210796, extension=TWW}, -- Mycobloom 1 star
        {id = 210797, extension=TWW}, -- Mycobloom 2 star
        {id = 210798, extension=TWW}, -- Mycobloom 3 star
        {id = 210808, extension=TWW}, -- Arathor's Spear 1 star
        {id = 210809, extension=TWW}, -- Arathor's Spear 2 star
        {id = 210810, extension=TWW}, -- Arathor's Spear 3 star
        {id = 210799, extension=TWW}, -- Luredrop 1 star
        {id = 210800, extension=TWW}, -- Luredrop 2 star
        {id = 210801, extension=TWW}, -- Luredrop 3 star
        {id = 210802, extension=TWW}, -- Orbinid 1 star
        {id = 210803, extension=TWW}, -- Orbinid 2 star
        {id = 210804, extension=TWW}, -- Orbinid 3 star
        {id = 210805, extension=TWW}, -- Blessing Blossom 1 star
        {id = 210806, extension=TWW}, -- Blessing Blossom 2 star
        {id = 210807, extension=TWW}, -- Blessing Blossom 3 star
        {id = 239690, extension=TWW}, -- Ghost Flower 1 star
        {id = 239691, extension=TWW}, -- Ghost Flower 2 star
        {id = 239692, extension=TWW}, -- Ghost Flower 3 star
        {id = 240194, extension=TWW}, -- K'areshi Lotus
        -- Midnight
        {id = 236774, extension=MN}, -- Azeroot Rose 1 star
        {id = 236775, extension=MN}, -- Azeroot Rose 2 star
        {id = 236761, extension=MN}, -- Tranquility Bloom 1 star
        {id = 236767, extension=MN}, -- Tranquility Bloom 2 star
        {id = 236770, extension=MN}, -- Sanguithorn 1 star
        {id = 236771, extension=MN}, -- Sanguithorn 2 star
        {id = 236776, extension=MN}, -- Argentleaf 1 star
        {id = 236777, extension=MN}, -- Argentleaf 2 star
        {id = 236778, extension=MN}, -- Mana Lily 1 star
        {id = 236779, extension=MN}, -- Mana Lily 2 star
        {id = 236780, extension=MN}, -- nocturnal-lotus
    },       
    SKINNING = {
        -- The War Within
        {id = 212670, extension=TWW}, -- Thunderous Hide 1 star
        {id = 212672, extension=TWW}, -- Thunderous Hide 2 star
        {id = 212673, extension=TWW}, -- Thunderous Hide 3 star
        {id = 212664, extension=TWW}, -- Stormvcharge Leather 1 star
        {id = 212665, extension=TWW}, -- Stormvcharge Leather 2 star 
        {id = 212666, extension=TWW}, -- Stormvcharge Leather 3 star
        {id = 212667, extension=TWW}, -- Gloom chitin 1 star
        {id = 212668, extension=TWW}, -- Gloom chitin 2 star
        {id = 212669, extension=TWW}, -- Gloom chitin 3 star
        {id = 212674, extension=TWW}, -- Sunless Carapace 1 star
        {id = 212675, extension=TWW}, -- Sunless Carapace 2 star
        {id = 212676, extension=TWW}, -- Sunless Carapace 3 star
        -- Midnight
        {id = 238511, extension=MN}, -- Void-Tempered Leather 1 star
        {id = 238512, extension=MN}, -- Void-Tempered Leather 2 star
        {id = 238513, extension=MN}, -- Void-Tempered Scales 1 star
        {id = 238514, extension=MN}, -- Void-Tempered Scales 2 star
        {id = 238520, extension=MN}, -- Void-Tempered Plating 1 star
        {id = 238521, extension=MN}, -- Void-Tempered Plating 2 star
        {id = 238518, extension=MN}, -- Void-Tempered Hide 1 star
        {id = 238519, extension=MN}, -- Void-Tempered Hide 2 star
        {id = 238523, extension=MN}, -- Carving Canine
        {id = 238522, extension=MN}, -- Peerless Plumage
        {id = 238525, extension=MN}, -- Fantastic Fur
        {id = 238529, extension=MN}, -- Majestic Hide
        {id = 238530, extension=MN}, -- Majestic Fin
    },
    FISHING = {
        -- The War Within
        {id = 220134, extension=TWW}, -- Dilly-Dilly Dace
        {id = 220135, extension=TWW}, -- Bloody Perch
        {id = 220136, extension=TWW}, -- Crystalline Sturgeon
        {id = 220137, extension=TWW}, -- Bismuth Bitterling
        {id = 220138, extension=TWW}, -- Nibbling Minnow
        {id = 220139, extension=TWW}, -- Whispering Stargazer
        {id = 220141, extension=TWW}, -- Specular Rainbowfish
        {id = 220142, extension=TWW}, -- Quiet River Bass
        {id = 220143, extension=TWW}, -- Dornish Pike
        {id = 220144, extension=TWW}, -- Roaring Anglerseeker
        {id = 220145, extension=TWW}, -- Arathor Hammerfish
        {id = 220146, extension=TWW}, -- Regal Dottyback
        {id = 220147, extension=TWW}, -- Kaheti Slum Shark
        {id = 220148, extension=TWW}, -- Pale Huskfish
        {id = 220149, extension=TWW}, -- Sanguine Dogfish
        {id = 220150, extension=TWW}, -- Spiked Sea Raven
        {id = 220151, extension=TWW}, -- Queen's Lurefish
        {id = 220152, extension=TWW}, -- Cursed Ghoulfish
        {id = 220153, extension=TWW}, -- Awoken Coelacanth
        {id = 222533, extension=TWW}, -- Goldendill Trout
        {id = 227673, extension=TWW}, -- "Gold" Fish
        -- Midnight
        {id = 238365, extension=MN}, -- Sin'dorei Swarmer
        {id = 238366, extension=MN}, -- Lynxfish
        {id = 238367, extension=MN}, -- Root Crab
        {id = 238368, extension=MN}, -- Twisted Tetra
        {id = 238369, extension=MN}, -- Bloomtail Minnow
        {id = 238370, extension=MN}, -- Shimmer Spinefish
        {id = 238371, extension=MN}, -- Arcane Wyrmfish
        {id = 238372, extension=MN}, -- Restored Songfish
        {id = 238373, extension=MN}, -- Ominous Octopus
        {id = 238374, extension=MN}, -- Tender Lumifin
        {id = 238375, extension=MN}, -- Fungalskin Pike
        {id = 238376, extension=MN}, -- Lucky Loa
        {id = 238378, extension=MN}, -- Shimmersiren
        {id = 238379, extension=MN}, -- Warping Wise
        {id = 238380, extension=MN}, -- Null Voidfish
        {id = 238381, extension=MN}, -- Hollow Grouper
        {id = 238382, extension=MN}, -- Gore Guppy
        {id = 238383, extension=MN}, -- Eversong Trout
        {id = 238384, extension=MN}, -- Sunwell Fish
    }
}