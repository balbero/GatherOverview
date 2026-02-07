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
        {id = 210930, quality=ONESTAR, extension=TWW}, -- Bismuth Ore 1 star
        {id = 210931, quality=TWOSTAR, extension=TWW}, -- Bismuth Ore 2 star
        {id = 210932, quality=THREESTAR, extension=TWW}, -- Bismuth Ore 3 star
        {id = 210936, quality=ONESTAR, extension=TWW}, -- Ironclaw Ore 1 star
        {id = 210937, quality=TWOSTAR, extension=TWW}, -- Ironclaw Ore 2 star
        {id = 210938, quality=THREESTAR, extension=TWW}, -- Ironclaw Ore 3 star
        {id = 210933, quality=ONESTAR, extension=TWW}, -- Aquirite Ore 1 star
        {id = 210934, quality=TWOSTAR, extension=TWW}, -- Aquirite Ore 2 star  
        {id = 210935, quality=THREESTAR, extension=TWW}, -- Aquirite Ore 3 star
        {id = 238201, quality=ONESTAR, extension=TWW}, -- Desolate Talus 1 star
        {id = 238212, quality=TWOSTAR, extension=TWW}, -- Desolate Talus 2 star
        {id = 238213, quality=THREESTAR, extension=TWW}, -- Desolate Talus 3 star
        {id = 240216, quality=NONE, extension=TWW}, --K'areshi Resonating Stone
        -- Midnight
        {id = 237359, quality=ONESTAR, extension=MN}, -- Refulgent Copper Ore 1 star
        {id = 237361, quality=TWOSTAR, extension=MN}, -- Refulgent Copper Ore 2 star
        {id = 237362, quality=ONESTAR, extension=MN}, -- Umbral Tin Ore 1 star
        {id = 237363, quality=TWOSTAR, extension=MN}, -- Umbral Tin Ore 2 star
        {id = 237364, quality=ONESTAR, extension=MN}, -- Brilliant Silver Ore 1 star
        {id = 237365, quality=TWOSTAR, extension=MN}, -- Brilliant Silver Ore 2 star
        {id = 237366, quality=NONE, extension=MN}, -- Dazzling Thorium
    },
    HERBALISM = {
        -- The War Within
        {id = 210796, quality=ONESTAR, extension=TWW}, -- Mycobloom 1 star
        {id = 210797, quality=TWOSTAR, extension=TWW}, -- Mycobloom 2 star
        {id = 210798, quality=THREESTAR, extension=TWW}, -- Mycobloom 3 star
        {id = 210808, quality=ONESTAR, extension=TWW}, -- Arathor's Spear 1 star
        {id = 210809, quality=TWOSTAR, extension=TWW}, -- Arathor's Spear 2 star
        {id = 210810, quality=THREESTAR, extension=TWW}, -- Arathor's Spear 3 star
        {id = 210799, quality=ONESTAR, extension=TWW}, -- Luredrop 1 star
        {id = 210800, quality=TWOSTAR, extension=TWW}, -- Luredrop 2 star
        {id = 210801, quality=THREESTAR, extension=TWW}, -- Luredrop 3 star
        {id = 210802, quality=ONESTAR, extension=TWW}, -- Orbinid 1 star
        {id = 210803, quality=TWOSTAR, extension=TWW}, -- Orbinid 2 star
        {id = 210804, quality=THREESTAR, extension=TWW}, -- Orbinid 3 star
        {id = 210805, quality=ONESTAR, extension=TWW}, -- Blessing Blossom 1 star
        {id = 210806, quality=TWOSTAR, extension=TWW}, -- Blessing Blossom 2 star
        {id = 210807, quality=THREESTAR, extension=TWW}, -- Blessing Blossom 3 star
        {id = 239690, quality=ONESTAR, extension=TWW}, -- Ghost Flower 1 star
        {id = 239691, quality=TWOSTAR, extension=TWW}, -- Ghost Flower 2 star
        {id = 239692, quality=THREESTAR, extension=TWW}, -- Ghost Flower 3 star
        {id = 240194, quality=NONE, extension=TWW}, -- K'areshi Lotus
        -- Midnight
        {id = 236774, quality=ONESTAR, extension=MN}, -- Azeroot Rose 1 star
        {id = 236775, quality=TWOSTAR, extension=MN}, -- Azeroot Rose 2 star
        {id = 236761, quality=ONESTAR, extension=MN}, -- Tranquility Bloom 1 star
        {id = 236767, quality=TWOSTAR, extension=MN}, -- Tranquility Bloom 2 star
        {id = 236770, quality=ONESTAR, extension=MN}, -- Sanguithorn 1 star
        {id = 236771, quality=TWOSTAR, extension=MN}, -- Sanguithorn 2 star
        {id = 236776, quality=ONESTAR, extension=MN}, -- Argentleaf 1 star
        {id = 236777, quality=TWOSTAR, extension=MN}, -- Argentleaf 2 star
        {id = 236778, quality=ONESTAR, extension=MN}, -- Mana Lily 1 star
        {id = 236779, quality=TWOSTAR, extension=MN}, -- Mana Lily 2 star
        {id = 236780, quality=NONE, extension=MN}, -- nocturnal-lotus
    },        
    SKINNING = {
        -- The War Within
        {id = 212670, quality=ONESTAR, extension=TWW}, -- Thunderous Hide 1 star
        {id = 212672, quality=TWOSTAR, extension=TWW}, -- Thunderous Hide 2 star
        {id = 212673, quality=THREESTAR, extension=TWW}, -- Thunderous Hide 3 star
        {id = 212664, quality=ONESTAR, extension=TWW}, -- Stormvcharge Leather 1 star
        {id = 212665, quality=TWOSTAR, extension=TWW}, -- Stormvcharge Leather 2 star 
        {id = 212666, quality=THREESTAR, extension=TWW}, -- Stormvcharge Leather 3 star
        {id = 212667, quality=ONESTAR, extension=TWW}, -- Gloom chitin 1 star
        {id = 212668, quality=TWOSTAR, extension=TWW}, -- Gloom chitin 2 star
        {id = 212669, quality=THREESTAR, extension=TWW}, -- Gloom chitin 3 star
        {id = 212674, quality=ONESTAR, extension=TWW}, -- Sunless Carapace 1 star
        {id = 212675, quality=TWOSTAR, extension=TWW}, -- Sunless Carapace 2 star
        {id = 212676, quality=THREESTAR, extension=TWW}, -- Sunless Carapace 3 star
        -- Midnight
        {id = 238511, quality=ONESTAR, extension=MN}, -- Void-Tempered Leather 1 star
        {id = 238512, quality=TWOSTAR, extension=MN}, -- Void-Tempered Leather 2 star
        {id = 238513, quality=ONESTAR, extension=MN}, -- Void-Tempered Scales 1 star
        {id = 238514, quality=TWOSTAR, extension=MN}, -- Void-Tempered Scales 2 star
        {id = 238520, quality=ONESTAR, extension=MN}, -- Void-Tempered Plating 1 star
        {id = 238521, quality=TWOSTAR, extension=MN}, -- Void-Tempered Plating 2 star
        {id = 238518, quality=ONESTAR, extension=MN}, -- Void-Tempered Hide 1 star
        {id = 238519, quality=TWOSTAR, extension=MN}, -- Void-Tempered Hide 2 star
        {id = 238523, quality=NONE, extension=MN}, -- Carving Canine
        {id = 238522, quality=NONE, extension=MN}, -- Peerless Plumage
        {id = 238525, quality=NONE, extension=MN}, -- Fantastic Fur
        {id = 238529, quality=NONE, extension=MN}, -- Majestic Hide
        {id = 238530, quality=NONE, extension=MN}, -- Majestic Fin
    },
    FISHING = {
        -- The War Within
        {id = 220134, quality=NONE, extension=TWW}, -- Dilly-Dilly Dace
        {id = 220135, quality=NONE, extension=TWW}, -- Bloody Perch
        {id = 220136, quality=NONE, extension=TWW}, -- Crystalline Sturgeon
        {id = 220137, quality=NONE, extension=TWW}, -- Bismuth Bitterling
        {id = 220138, quality=NONE, extension=TWW}, -- Nibbling Minnow
        {id = 220139, quality=NONE, extension=TWW}, -- Whispering Stargazer
        {id = 220141, quality=NONE, extension=TWW}, -- Specular Rainbowfish
        {id = 220142, quality=NONE, extension=TWW}, -- Quiet River Bass
        {id = 220143, quality=NONE, extension=TWW}, -- Dornish Pike
        {id = 220144, quality=NONE, extension=TWW}, -- Roaring Anglerseeker
        {id = 220145, quality=NONE, extension=TWW}, -- Arathor Hammerfish
        {id = 220146, quality=NONE, extension=TWW}, -- Regal Dottyback
        {id = 220147, quality=NONE, extension=TWW}, -- Kaheti Slum Shark
        {id = 220148, quality=NONE, extension=TWW}, -- Pale Huskfish
        {id = 220149, quality=NONE, extension=TWW}, -- Sanguine Dogfish
        {id = 220150, quality=NONE, extension=TWW}, -- Spiked Sea Raven
        {id = 220151, quality=NONE, extension=TWW}, -- Queen's Lurefish
        {id = 220152, quality=NONE, extension=TWW}, -- Cursed Ghoulfish
        {id = 220153, quality=NONE, extension=TWW}, -- Awoken Coelacanth
        {id = 222533, quality=NONE, extension=TWW}, -- Goldendill Trout
        {id = 227673, quality=NONE, extension=TWW}, -- "Gold" Fish
        -- Midnight
        {id = 238365, quality=NONE, extension=MN}, -- Sin'dorei Swarmer
        {id = 238366, quality=NONE, extension=MN}, -- Lynxfish
        {id = 238367, quality=NONE, extension=MN}, -- Root Crab
        {id = 238368, quality=NONE, extension=MN}, -- Twisted Tetra
        {id = 238369, quality=NONE, extension=MN}, -- Bloomtail Minnow
        {id = 238370, quality=NONE, extension=MN}, -- Shimmer Spinefish
        {id = 238371, quality=NONE, extension=MN}, -- Arcane Wyrmfish
        {id = 238372, quality=NONE, extension=MN}, -- Restored Songfish
        {id = 238373, quality=NONE, extension=MN}, -- Ominous Octopus
        {id = 238374, quality=NONE, extension=MN}, -- Tender Lumifin
        {id = 238375, quality=NONE, extension=MN}, -- Fungalskin Pike
        {id = 238376, quality=NONE, extension=MN}, -- Lucky Loa
        {id = 238378, quality=NONE, extension=MN}, -- Shimmersiren
        {id = 238379, quality=NONE, extension=MN}, -- Warping Wise
        {id = 238380, quality=NONE, extension=MN}, -- Null Voidfish
        {id = 238381, quality=NONE, extension=MN},  -- Hollow Grouper
        {id = 238382, quality=NONE, extension=MN}, -- Gore Guppy
        {id = 238383, quality=NONE, extension=MN}, -- Eversong Trout
        {id = 238384, quality=NONE, extension=MN}, -- Sunwell Fish
    }
}