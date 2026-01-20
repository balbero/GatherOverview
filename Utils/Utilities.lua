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
