---@class addonTableGatherOverview
local addonTable = select(2, ...)

addonTable.Constants = {
    IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE,
    IsMidnight = select(4, GetBuildInfo()) >= 120000,
}