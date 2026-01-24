---@class addonTableGatherOverview
local addonTable = select(2, ...)

function addonTable.Utilities.Message(text)
  print("|cff96742a" .. addonTable.Locales.GATHER_OVERVIEW .. "|r: " .. text)
end

--scale
function addonTable.Utilities.Scale (rangeMin, rangeMax, scaleMin, scaleMax, x)
	return 1 + (x - rangeMin) * (scaleMax - scaleMin) / (rangeMax - rangeMin)
end

--font size
function addonTable.Utilities.SetFontSize(fontString, ...)
	local font, _, flags = fontString:GetFont()
	fontString:SetFont(font, math.max (...), flags)
end
function addonTable.Utilities.GetFontSize (fontString)
	local _, size = fontString:GetFont()
	return size
end

function tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end
