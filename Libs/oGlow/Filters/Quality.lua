local quality = function(...)
	local quality = -1

	for i = 1, select("#", ...) do
		local itemLink = select(i, ...)

		if itemLink then
			local _, _, itemQuality = C_Item.GetItemInfo(itemLink)

			if itemQuality then
				quality = math.max(quality, itemQuality)
			end
		end
	end

	if quality >= 1 then  -- Changed from > 1 to >= 1 to include common (white) items
		return quality
	end
end

oGlow:RegisterFilter("Quality border", "Border", quality)