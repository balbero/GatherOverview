---@class addonTableGatherOverview
local addonTable = select(2, ...)

addonTable.Constants = {
    IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
    IsMidnight = select(4, GetBuildInfo()) >= 120001,
    DB_VERSION = 2,
    -- Extension identifiers
    EXT_TWW     = 11,
    EXT_MN      = 12,
    -- Professions
    MINING          = 101,
    BLACKSMITH      = 102,
    HERBALISM       = 103,
    ALCHEMY         = 104,
    SKINNING        = 105,
    LEATHERWORKING  = 106,
    ENCHANTING      = 107,
    ENGiNEERING     = 108,
    TAILORING       = 109,
    INCRIPTION      = 110,
    JEWALCRAFTING   = 111,
    FISHING         = 112,
    OTHER_STUFF     = 115,
}