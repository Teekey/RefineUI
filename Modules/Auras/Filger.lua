local R, C, L = unpack(RefineUI)
if C.filger.enable ~= true then return end

----------------------------------------------------------------------------------------
--	Lightweight buff/debuff tracking (Filger by Nils Ruesch, editors Affli/SinaC/Ildyria)
----------------------------------------------------------------------------------------
LEFT_BUFF_Anchor:SetPoint(unpack(C.position.filger.left_buff))
LEFT_BUFF_Anchor:SetSize(C.filger.buffs_size, C.filger.buffs_size)

RIGHT_BUFF_Anchor:SetPoint(unpack(C.position.filger.right_buff))
RIGHT_BUFF_Anchor:SetSize(C.filger.buffs_size, C.filger.buffs_size)

BOTTOM_BUFF_Anchor:SetPoint(unpack(C.position.filger.bottom_buff))
BOTTOM_BUFF_Anchor:SetSize(C.filger.buffs_size, C.filger.buffs_size)

SpellActivationOverlayFrame:SetFrameStrata("BACKGROUND")

local Filger = {}
local MyUnits = {player = true, vehicle = true, pet = true}
local SpellGroups = {}

function Filger:TooltipOnEnter()
	if self.spellID > 20 then
		local str = "spell:%s"
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 3)
		GameTooltip:SetHyperlink(format(str, self.spellID))
		GameTooltip:Show()
	end
end

function Filger:TooltipOnLeave()
	GameTooltip:Hide()
end

function Filger:UpdateCD()
	local time = self.value.start + self.value.duration - GetTime()

	if time < 0 then
		local frame = self:GetParent()
		frame.actives[self.value.spid] = nil
		self:SetScript("OnUpdate", nil)
		Filger.DisplayActives(frame)
	end
end

function Filger:DisplayActives()
	if not self.actives then return end
	if not self.bars then self.bars = {} end
	local id = self.Id
	local index = 1
	local previous = nil
	local temp = {}

	for _, value in pairs(self.actives) do
		local bar = self.bars[index]
		if not bar then
			bar = CreateFrame("Frame", "FilgerAnchor"..id.."Frame"..index, self)
			bar:SetTemplate("Icon")
			if index == 1 then
				bar:SetPoint(unpack(self.Position))
			else
				if self.Direction == "UP" then
					bar:SetPoint("BOTTOM", previous, "TOP", 0, self.Interval)
				elseif self.Direction == "RIGHT" then
					bar:SetPoint("LEFT", previous, "RIGHT", self.Interval, 0)
				elseif self.Direction == "LEFT" then
					bar:SetPoint("RIGHT", previous, "LEFT", -self.Interval, 0)
				else
					bar:SetPoint("TOP", previous, "BOTTOM", 0, -self.Interval)
				end
			end

			bar.icon = bar:CreateTexture("$parentIcon", "BORDER")
			bar.icon:SetPoint("TOPLEFT", 2, -2)
			bar.icon:SetPoint("BOTTOMRIGHT", -2, 2)
			bar.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

			bar.cooldown = CreateFrame("Cooldown", "$parentCD", bar, "CooldownFrameTemplate")
			bar.cooldown:SetAllPoints(bar.icon)
			bar.cooldown:SetReverse(true)
			bar.cooldown:SetDrawEdge(false)
			bar.cooldown:SetFrameLevel(3)

			bar.count = bar:CreateFontString("$parentCount", "OVERLAY")
			bar.count:SetFont(unpack(C.font.filger.count))
			bar.count:SetShadowOffset(1, -1)
			bar.count:SetPoint("BOTTOMRIGHT", 1, -2)
			bar.count:SetJustifyH("RIGHT")

			self.bars[index] = bar
		end
		previous = bar
		index = index + 1
		table.insert(temp, value)
	end

	local function sortTable(a, b)
		if C.filger.expiration == true and a.data.filter == "CD" then
			return a.start + a.duration < b.start + b.duration
		else
			return a.sort < b.sort
		end
	end
	table.sort(temp, sortTable)

	local limit = (C.actionbars.buttonSize * 12)/self.IconSize

	index = 1
	for activeIndex, value in pairs(temp) do
		if activeIndex >= limit then
			break
		end
		local bar = self.bars[index]
		bar.spellName = GetSpellInfo(value.spid)
		bar.icon:SetTexture(value.icon)
		if value.count and value.count > 1 then
			bar.count:SetText(value.count)
			bar.count:Show()
		else
			bar.count:Hide()
		end
		if value.duration and value.duration > 0 then
			if value.start + value.duration - GetTime() > 0.3 then
				bar.cooldown:SetCooldown(value.start + 0.1, value.duration)
			end
			if value.data.filter == "CD" or value.data.filter == "ICD" then
				bar.value = value
				bar:SetScript("OnUpdate", Filger.UpdateCD)
			else
				bar:SetScript("OnUpdate", nil)
			end
			bar.cooldown:Show()
		else
			bar.cooldown:Hide()
			bar:SetScript("OnUpdate", nil)
		end
		bar.spellID = value.spid
		if C.filger.show_tooltip then
			bar:EnableMouse(true)
			bar:SetScript("OnEnter", Filger.TooltipOnEnter)
			bar:SetScript("OnLeave", Filger.TooltipOnLeave)
		end
		bar:SetWidth(self.IconSize or C.filger.buffs_size)
		bar:SetHeight(self.IconSize or C.filger.buffs_size)
		bar:SetAlpha(value.data.opacity or 1)
		bar:Show()

		-- Adjust frame levels
		bar.cooldown:SetFrameLevel(bar:GetFrameLevel() + 1)
		bar.cooldown:SetSwipeTexture("Interface\\AddOns\\RefineUI\\Media\\Textures\\CDBig.blp")
		bar.cooldown:SetPoint("TOPLEFT", bar, "TOPLEFT", -1, 1)
		bar.cooldown:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 1, -1)
		
		-- Add duration text
		if not bar.duration then
			bar.duration = bar:CreateFontString(nil, "OVERLAY")
			bar.duration:SetParent(bar.cooldown)
			bar.duration:SetFont(unpack(C.font.filger.time))
			bar.duration:SetShadowOffset(1, -1)
			bar.duration:SetPoint("CENTER", 0, 0)
		end
		
		if value.duration and value.duration > 0 then
			bar.duration:Show()
			bar:SetScript("OnUpdate", function(self, elapsed)
				self.elapsed = (self.elapsed or 0) + elapsed
				if self.elapsed >= 0.1 then
					local timeLeft = value.start + value.duration - GetTime()
					if timeLeft > 0 then
						self.duration:SetText(R.FormatTime(timeLeft))
					else
						self.duration:SetText("")
						self:SetScript("OnUpdate", nil)
					end
					self.elapsed = 0
				end
			end)
		else
			bar.duration:Hide()
			bar:SetScript("OnUpdate", nil)
		end

		-- Set the border color
		if value.data.color then
			bar.border:SetBackdropBorderColor(unpack(value.data.color))
		else
			local r, g, b = unpack(R.oUF_colors.class[R.class])
			bar.border:SetBackdropBorderColor(r, g, b, 1)
		end

		index = index + 1
	end

	for i = index, #self.bars, 1 do
		local bar = self.bars[i]
		bar:Hide()
	end
end

local function FindAuras(self, unit)
	for spid in pairs(self.actives) do
		if self.actives[spid].data.filter ~= "CD" and self.actives[spid].data.filter ~= "ICD" and self.actives[spid].data.unitID == unit then
			self.actives[spid] = nil
		end
	end

	for i = 1, 2 do
		local filter = (i == 1 and "HELPFUL" or "HARMFUL")
		local index = 1
		while true do
			local name, icon, count, _, duration, expirationTime, caster, _, _, spid = UnitAura(unit, index, filter)
			if not name then break end

			local data = SpellGroups[self.Id].spells[name] or SpellGroups[self.Id].spells[spid]
			if data and (data.caster ~= 1 and (caster == data.caster or data.caster == "all") or MyUnits[caster]) and (not data.unitID or data.unitID == unit) and (not data.absID or spid == data.spellID) then
				local isKnown = data.requireSpell and IsPlayerSpell(data.requireSpell)
				if ((data.filter == "BUFF" and filter == "HELPFUL") or (data.filter == "DEBUFF" and filter == "HARMFUL")) and (not data.spec or data.spec == R.Spec) and (not data.requireSpell or isKnown) then
					if not data.count or count >= data.count then
						self.actives[spid] = {data = data, name = name, icon = icon, count = count, start = expirationTime - duration, duration = duration, spid = spid, sort = data.sort, color = data.color}
					end
				elseif data.filter == "ICD" and (data.trigger == "BUFF" or data.trigger == "DEBUFF") and (not data.spec or data.spec == R.Spec) and (not data.requireSpell or isKnown) then
					if data.slotID then
						local slotLink = GetInventoryItemLink("player", data.slotID)
						_, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(slotLink)
					end
					self.actives[spid] = {data = data, name = name, icon = icon, count = count, start = expirationTime - duration, duration = data.duration, spid = spid, sort = data.sort, color = data.color}
				end
			end
			index = index + 1
		end
	end
	Filger.DisplayActives(self)
end

function Filger:OnEvent(event, unit, _, castID)
	if event == "UNIT_AURA" and (unit == "player" or unit == "target" or unit == "pet" or unit == "focus") then
		FindAuras(self, unit)
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" then
		local name, _, icon = GetSpellInfo(castID)
		local data = SpellGroups[self.Id].spells[name]
		if data and data.filter == "ICD" and data.trigger == "NONE" and (not data.spec or data.spec == R.Spec) then
			local start, duration = GetTime(), data.duration
			if data.totem then
				local haveTotem, _, startTime, durationTime = GetTotemInfo(1)
				if haveTotem then
					start, duration = startTime, durationTime
				end
			end
			self.actives[data.spellID] = {data = data, name = name, icon = icon, count = nil, start = start, duration = duration, spid = data.spellID, sort = data.sort, color = data.color}
			Filger.DisplayActives(self)
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		FindAuras(self, "target")
	elseif event == "PLAYER_FOCUS_CHANGED" then
		FindAuras(self, "focus")
	elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELL_UPDATE_COOLDOWN" then
		if event == "PLAYER_ENTERING_WORLD" then
			local _, instanceType = IsInInstance()
			if instanceType == "raid" or instanceType == "pvp" then
				if self:IsEventRegistered("UNIT_AURA") then
					self:UnregisterEvent("UNIT_AURA")
					self:SetScript("OnUpdate", function(timer, elapsed)
						timer.elapsed = (timer.elapsed or 0) + elapsed
						if timer.elapsed < 0.1 then return end
						timer.elapsed = 0
						for spid in pairs(self.actives) do
							if self.actives[spid].data.filter ~= "CD" and self.actives[spid].data.filter ~= "ICD" then
								self.actives[spid] = nil
							end
						end
						FindAuras(self, "player")
						if UnitExists("target") then
							FindAuras(self, "target")
						end
						if UnitExists("pet") then
							FindAuras(self, "pet")
						end
						if UnitExists("focus") then
							FindAuras(self, "focus")
						end
					end)
				end
			else
				if self:GetScript("OnUpdate") then
					self:SetScript("OnUpdate", nil)
					self:RegisterEvent("UNIT_AURA")
				end
			end

			for spid in pairs(self.actives) do
				if self.actives[spid].data.filter ~= "CD" and self.actives[spid].data.filter ~= "ICD" then
					self.actives[spid] = nil
				end
			end
			FindAuras(self, "player")
			if UnitExists("pet") then
				FindAuras(self, "pet")
			end
		elseif event == "SPELL_UPDATE_COOLDOWN" then
			for spid in pairs(self.actives) do
				if self.actives[spid].data.filter == "CD" then
					self.actives[spid] = nil
				end
			end
		end

		for i = 1, #C["filger_spells"][R.class][self.Id], 1 do
			local data = C["filger_spells"][R.class][self.Id][i]

			if data.filter == "CD" and (not data.spec or data.spec == R.Spec) then
				local name, icon, start, duration, spid
				if data.spellID then
					name, _, icon = GetSpellInfo(data.spellID)
					if name then
						if data.absID then
							start, duration = C_Spell.GetSpellCooldown(data.spellID)
						else
							start, duration = C_Spell.GetSpellCooldown(name)
						end
						spid = data.spellID
					end
				elseif data.slotID then
					spid = data.slotID
					local slotLink = GetInventoryItemLink("player", data.slotID)
					if slotLink then
						name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(slotLink)
						start, duration = GetInventoryItemCooldown("player", data.slotID)
					end
				end
				if name and (duration or 0) > 1.5 and duration < 900 then
					if not (R.class == "DEATHKNIGHT" and data.filter == "CD" and duration < 10) then -- Filter rune cd
						self.actives[spid] = {data = data, name = name, icon = icon, count = nil, start = start, duration = duration, spid = spid, sort = data.sort, color = data.color}
					end
				end
			end
		end

		Filger.DisplayActives(self)
	end
end

if C["filger_spells"] and C["filger_spells"]["ALL"] then
	if not C["filger_spells"][R.class] then
		C["filger_spells"][R.class] = {}
	end

	for i = 1, #C["filger_spells"]["ALL"], 1 do
		local merge = false
		local spellListAll = C["filger_spells"]["ALL"][i]
		local spellListClass = nil
		for j = 1, #C["filger_spells"][R.class], 1 do
			spellListClass = C["filger_spells"][R.class][j]
			local mergeAll = spellListAll.Merge or false
			local mergeClass = spellListClass.Merge or false
			if spellListClass.Name == spellListAll.Name and (mergeAll or mergeClass) then
				merge = true
				break
			end
		end
		if not merge or not spellListClass then
			table.insert(C["filger_spells"][R.class], C["filger_spells"]["ALL"][i])
		else
			for j = 1, #spellListAll, 1 do
				table.insert(spellListClass, spellListAll[j])
			end
		end
	end
end

for _, spell in pairs(C.filger.left_buffs_list) do
	if spell[2] == R.class then
		tinsert(R.CustomFilgerSpell, {"LEFT_BUFF", {spellID = spell[1], unitID = "player", caster = "player", filter = "BUFF", absID = true, custom = true}})
	end
end

for _, spell in pairs(C.filger.right_buffs_list) do
	if spell[2] == R.class then
		tinsert(R.CustomFilgerSpell, {"RIGHT_BUFF", {spellID = spell[1], unitID = "player", caster = "player", filter = "BUFF", absID = true, custom = true}})
	end
end

for _, spell in pairs(C.filger.bottom_buffs_list) do
	if spell[2] == R.class then
		tinsert(R.CustomFilgerSpell, {"BOTTOM_BUFF", {spellID = spell[1], unitID = "player", caster = "player", filter = "BUFF", absID = true, custom = true}})
	end
end

if C["filger_spells"] and C["filger_spells"][R.class] then
	for class in pairs(C["filger_spells"]) do
		if class ~= R.class then
			C["filger_spells"][class] = nil
		end
	end

	local idx = {}
	for i = 1, #C["filger_spells"][R.class], 1 do
		local jdx = {}
		local data = C["filger_spells"][R.class][i]
		local group = {spells = {}}

		for _, import in pairs(R.CustomFilgerSpell) do
			if data.Name == import[1] then
				tinsert(data, import[2])
			end
		end

		for j = 1, #data, 1 do
			local name
			if data[j].spellID then
				name = GetSpellInfo(data[j].spellID)
			else
				local slotLink = GetInventoryItemLink("player", data[j].slotID)
				if slotLink then
					name = C_Item.GetItemInfo(slotLink)
				end
			end
			if name or data[j].slotID then
				if R.FilgerIgnoreSpell[name] and not data[j].custom then
					table.insert(jdx, j)
				else
					local info = data[j].spellID and C_Spell.GetSpellInfo(data[j].spellID)
					local id = data[j].absID and data[j].spellID or (info and info.spellID) or data[j].slotID
					data[j].sort = j
					group.spells[id] = data[j]
				end
			end
			if not name and not data[j].slotID then
				print("|cffff0000ShestakUI: Filger spell ID ["..(data[j].spellID or data[j].slotID or "UNKNOWN").."] no longer exists!|r")
				table.insert(jdx, j)
			end
		end

		for _, v in ipairs(jdx) do
			table.remove(data, v)
		end

		group.data = data
		table.insert(SpellGroups, i, group)

		if #data == 0 then
			table.insert(idx, i)
		end
	end

	for _, v in ipairs(idx) do
		table.remove(C["filger_spells"][R.class], v)
	end

	local isEnabled = {
		["LEFT_BUFF"] = C.filger.show_buff,
		["RIGHT_BUFF"] = C.filger.show_proc,
		["T_DEBUFF_ICON"] = C.filger.show_debuff,
		["T_DE/BUFF_BAR"] = C.filger.show_aura_bar,
		["PVE/PVP_CC"] = C.filger.show_aura_bar,
		["BOTTOM_BUFF"] = C.filger.show_special,
		["PVE/PVP_DEBUFF"] = C.filger.show_pvp_player,
		["T_BUFF"] = C.filger.show_pvp_target,
		["COOLDOWN"] = C.filger.show_cd,
	}

	for i = 1, #SpellGroups, 1 do
		local data = SpellGroups[i].data
		if isEnabled[data.Name] then
			local frame = CreateFrame("Frame", "FilgerFrame"..i.."_"..data.Name, UIParent)
			frame.Id = i
			frame.Name = data.Name
			frame.Direction = data.Direction or "DOWN"
			frame.IconSide = data.IconSide or "LEFT"
			frame.Mode = "ICON"  -- Always use ICON mode
			frame.Interval = data.Interval or 3
			frame:SetAlpha(data.Alpha or 1)
			frame.IconSize = data.IconSize or C.filger.buffs_size
			frame.Position = data.Position or "CENTER"
			frame:SetPoint(unpack(data.Position))
			frame.actives = {}

			if C.filger.test_mode then
				frame.actives = {}
				for j = 1, math.min(C.filger.max_test_icon, #C["filger_spells"][R.class][i]), 1 do
					local data = C["filger_spells"][R.class][i][j]
					local name, icon
					if data.spellID then
						name, _, icon = GetSpellInfo(data.spellID)
					elseif data.slotID then
						local slotLink = GetInventoryItemLink("player", data.slotID)
						if slotLink then
							name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(slotLink)
						end
					end
					frame.actives[j] = {data = data, name = name, icon = icon, count = 9, start = 0, duration = 0, spid = data.spellID or data.slotID, sort = data.sort, color = data.color}
				end
				Filger.DisplayActives(frame)
			else
				for j = 1, #C["filger_spells"][R.class][i], 1 do
					local data = C["filger_spells"][R.class][i][j]
					if data.filter == "BUFF" or data.filter == "DEBUFF" or (data.filter == "ICD" and (data.trigger == "BUFF" or data.trigger == "DEBUFF")) then
						frame:RegisterEvent("UNIT_AURA")
					elseif data.filter == "CD" then
						frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
					elseif data.trigger == "NONE" then
						frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
					end
					if data.unitID == "target" then
						frame:RegisterEvent("PLAYER_TARGET_CHANGED")
					elseif data.unitID == "focus" then
						frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
					end
				end
				frame:RegisterEvent("PLAYER_ENTERING_WORLD")
				frame:SetScript("OnEvent", Filger.OnEvent)
			end
		end
	end
end