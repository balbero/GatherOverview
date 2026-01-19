---@class addonTableGatherOverview
local addonTable = select(2, ...)
addonTable.Colors = {
    red = { r = 1, g = 0.2, b = 0.2, a = 1 },
    orange = { r = 1, g = 0.6, b = 0.2, a = 1 },
    green = { r = 0.2, g = 1, b = 0.2, a = 1 },
    white = { r = 1, g = 1, b = 1, a = 1 },
}

function addonTable.Colors.GetColorForValue(profession, value)
    local professionSettings = addonTable.Config.Get(addonTable.Config.Options.PROFESSIONS)
    local prof = nil
    for _, p in pairs(professionSettings) do
        if p.name == profession then
            prof = p
            break
        end
    end
    if not prof then
        return addonTable.Colors.white
    end

    local low = prof.low or 50
    local high = prof.high or 100

    if value < low then
        return prof.low_color
    elseif value < high then
        return prof.medium_color
    else
        return prof.high_color
    end
end