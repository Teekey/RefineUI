local R, C, L = unpack(RefineUI)

-- local Mult = R.mult
-- if R.screenHeight > 1200 then
-- 	Mult = R.Scale(1)
-- end

local colorTable = setmetatable(
	{},
	{
		__index = function(self, val)
			local r, g, b = C_Item.GetItemQualityColor(val)
			rawset(self, val, { r, g, b })

			return self[val]
		end
	}
)

local createBorder = function(self, point)
	local border = self.oGlowBorder
	if not border then
		self:SetTemplate("Icon")
		self.oGlowBorder = self.border
	end

	return border
end

local borderDisplay = function(frame, color)
	if color then
		local border = createBorder(frame)
		local rgb = colorTable[color]

		if rgb then
			frame.border:SetBackdropBorderColor(rgb[1], rgb[2], rgb[3])
		end

		return true
	elseif frame.oGlowBorder then
		frame.oGlowBorder:Hide()
	end
end

function oGlow:RegisterColor(name, r, g, b)
	if rawget(colorTable, name) then
		return nil, string.format("Color [%s] is already registered.", name)
	else
		rawset(colorTable, name, { r, g, b })
	end

	return true
end

oGlow:RegisterDisplay("Border", borderDisplay)
