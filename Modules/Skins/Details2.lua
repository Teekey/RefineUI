local R, C, L = unpack(RefineUI)
if not C_AddOns.IsAddOnLoaded("Details") then return end

----------------------------------------------------------------------------------------
--	Details skin
----------------------------------------------------------------------------------------
hooksecurefunc(_detalhes.gump, "CreateNewLine", function(_, instancia, index)
	local bar = _G["DetailsBarra_"..instancia.meu_id.."_"..index]
	local icon = _G["DetailsBarra_IconFrame_"..instancia.meu_id.."_"..index]

	if bar and not bar.backdrop then
		bar:CreateBackdrop("Default")
		bar.backdrop:SetPoint("TOPLEFT", icon, -2, 2)

		bar.bg = bar:CreateTexture(nil, "BORDER")
		bar.bg:SetAllPoints(bar)
		bar.bg:SetTexture(C.media.texture)
		bar.bg:SetVertexColor(.6, .6, .6, 0.25)
	end

	local frame = _G["DetailsUpFrameInstance"..instancia.meu_id]
	if not frame.b then
		frame.b = CreateFrame("Frame", nil, frame:GetParent())
		frame.b:SetTemplate("Overlay")
		frame.b:SetPoint("TOPLEFT", frame, "TOPLEFT", -23, 2)
		frame.b:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 34, 4)
		frame.b:SetFrameLevel(frame:GetFrameLevel() - 1)
	end
end)

hooksecurefunc(_detalhes, "SetFontOutline", function(_, fontString)
	local fonte, size = fontString:GetFont()
	if fonte == "Interface\\AddOns\\RefineUI\\Media\\Fonts\\Pixel.ttf" then
		fontString:SetFont(fonte, size, "MONOCHROMEOUTLINE")
		if fontString:GetShadowColor() then
			fontString:SetShadowColor(0, 0, 0, 0)
		end
	end
end)


local function UpdateDetailsPosition()
    local minimapAnchor = _G["MinimapAnchor"]
    if not minimapAnchor then return end

    local detailsFrame = _G["DetailsBaseFrame1"] -- Adjust if your Details frame has a different name
    if not detailsFrame then return end

    local minimapLeft = minimapAnchor:GetLeft()
    local minimapTop = minimapAnchor:GetTop()
    local minimapBottom = minimapAnchor:GetBottom()
    local minimapWidth = minimapAnchor:GetWidth()

    local titleMenuHeight = 36 -- Adjust this value based on your title menu's actual height

    -- Position Details to the left of the minimap, accounting for the title menu
    detailsFrame:ClearAllPoints()
    detailsFrame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", minimapLeft - 7, minimapTop - titleMenuHeight)
    detailsFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", minimapLeft - 7, minimapBottom - 6)
    
    -- Set the width to match the minimap
    detailsFrame:SetWidth(minimapWidth - 6)
end

-- Hook the update function to relevant events
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- Delay the initial positioning to ensure all addons are loaded
        C_Timer.After(1, UpdateDetailsPosition)
    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateDetailsPosition()
    end
end)

local skinTable = {
	file = [[Interface\AddOns\RefineUI\Media\Textures\Texture.tga]],
	author = "Teekey",
	version = "1.0",
	site = "unknown",
	desc = "RefineUI style skin.",

	--micro frames
	micro_frames = {
		color = {1, 1, 1, 1},
		font = "ITCAvantGardeStd-Demi",
		size = 8,
		textymod = 1,
	},

	can_change_alpha_head = true,
	icon_anchor_main = {-1, -5},
	icon_anchor_plugins = {-7, -13},
	icon_plugins_size = {19, 18},

	--anchors:
	icon_point_anchor = {-37, 0},
	left_corner_anchor = {-107, 0},
	right_corner_anchor = {96, 0},

	icon_point_anchor_bottom = {-37, 12},
	left_corner_anchor_bottom = {-107, 0},
	right_corner_anchor_bottom = {96, 0},

	icon_on_top = true,
	icon_ignore_alpha = true,
	icon_titletext_position = {3, 3},

	--overwrites
	instance_cprops = {
		["show_statusbar"] = false,
		["menu_icons_size"] = 0.9,
		["toolbar_icon_file"] = "Interface\\AddOns\\Details\\images\\toolbar_icons_2_shadow",
		["auto_hide_menu"] = {
			["left"] = true,
		},
		["color"] = {
			0, -- [1]
			0, -- [2]
			0, -- [3]
			0, -- [4]
		},
		["menu_anchor"] = {
			16, -- [1]
			14, -- [2]
			["side"] = 2,
		},
		["bg_r"] = 1,
		["hide_out_of_combat"] = false,
		["following"] = {
			["bar_color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
			},
			["enabled"] = true,
			["text_color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
			},
		},
		["color_buttons"] = {
			1, -- [1]
			1, -- [2]
			1, -- [3]
			1, -- [4]
		},
        ["skin_custom"] = "",
		["menu_anchor_down"] = {
			16, -- [1]
			-3, -- [2]
		},
		["micro_displays_locked"] = true,
		["row_show_animation"] = {
			["anim"] = "Fade",
			["options"] = {
			},
		},
		["tooltip"] = {
			["n_abilities"] = 3,
			["n_enemies"] = 3,
		},
		["total_bar"] = {
			["enabled"] = false,
			["only_in_group"] = true,
			["icon"] = "Interface\\ICONS\\INV_Sigil_Thorim",
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
			},
		},
		["show_sidebars"] = false,
		["instance_button_anchor"] = {
			-27, -- [1]
			1, -- [2]
		},
		["row_info"] = {
			["spec_file"] = "Interface\\AddOns\\Details\\images\\spec_icons_normal",
			["text_yoffset"] = -1, -- Increase this value by 1 to move left text down
			["textL_outline"] = true,
			["textR_outline"] = true,
			["textL_outline_small"] = true,
			["textR_outline_small"] = true,
			["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
            textR_show_data = {
                false, -- [1] Set to false to hide totals
                true,  -- [2] DPS
                true,  -- [3] Percentage
            },
			["textL_enable_custom_text"] = false,
			["fixed_text_color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
			},
			["space"] = {
				["right"] = 0,
				["left"] = 0,
				["between"] = 9,
			},
			["texture_background_class_color"] = false,
			["start_after_icon"] = true,
			["font_face_file"] = "Interface\\AddOns\\RefineUI\\Media\\Fonts\\Pixel.ttf",
			["backdrop"] = {
				["enabled"] = false,
				["size"] = 12,
				["color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
					1, -- [4]
				},
				["texture"] = "Details BarBorder 2",
			},
			["font_size"] = 14,
			["height"] = 18,
			["texture_file"] = "AddOns\\RefineUI\\Media\\Textures\\Texture.tga",
			["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small",
			["textR_bracket"] = "(",
			["textR_enable_custom_text"] = false,
			["fixed_texture_color"] = {
				0, -- [1]
				0, -- [2]
				0, -- [3]
			},
			["textL_show_number"] = true,
			["textL_custom_text"] = "{data1}. {data3}{data2}",
			["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
			["fixed_texture_background_color"] = {
				0, -- [1]
				0, -- [2]
				0, -- [3]
				0, -- [4]
			},
			["models"] = {
				["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
				["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
				["upper_alpha"] = 0.5,
				["lower_enabled"] = false,
				["lower_alpha"] = 0.1,
				["upper_enabled"] = false,
			},
			["textR_class_colors"] = false,
			["texture_custom"] = "AddOns\\RefineUI\\Media\\Textures\\TKUITexture.tga",
			["texture"] = "Smooth!",
			["textL_class_colors"] = false,
			["alpha"] = 1,
			["no_icon"] = false,
			["texture_background"] = "Smooth!",
			["texture_background_file"] = "AddOns\\RefineUI\\Media\\Textures\\Texture.tga",
			["font_face"] = "ITCAvantGardeStd-Demi",
			["font_shadow"] = "OUTLINE",
			["texture_class_colors"] = true,
			["percent_type"] = 1,
			["fast_ps_update"] = false,
			["textR_separator"] = ",",
			["use_spec_icons"] = true,
		},
		["plugins_grow_direction"] = 1,
		["menu_alpha"] = {
			["enabled"] = false,
			["onleave"] = 1,
			["ignorebars"] = false,
			["iconstoo"] = true,
			["onenter"] = 1,
		},
		["micro_displays_side"] = 2,
		["grab_on_top"] = false,
		["strata"] = "LOW",
		["bars_grow_direction"] = 1,
		["bg_alpha"] = 0,
		["ignore_mass_showhide"] = false,
		["hide_in_combat_alpha"] = 0,
		["menu_icons"] = {
			true, -- [1]
			true, -- [2]
			true, -- [3]
			true, -- [4]
			true, -- [5]
			false, -- [6]
			["space"] = -2,
			["shadow"] = false,
		},
		-- ["auto_hide_menu"] = {
		-- 	["left"] = true,
		-- 	["right"] = true,
		-- },
		["statusbar_info"] = {
			["alpha"] = 0,
			["overlay"] = {
				0.333333333333333, -- [1]
				0.333333333333333, -- [2]
				0.333333333333333, -- [3]
			},
		},
        ["window_scale"] = 1, -- Keep this at 1 unless you want additional scaling
        ["window_width"] = 300, -- Set your desired width here
        ["window_height"] = 150, -- Set your desired height here
		["libwindow"] = {
            ["y"] = 300,
            ["x"] = 300,
			["point"] = "BOTTOMRIGHT",
		},
		["backdrop_texture"] = "Details Ground",
		["hide_icon"] = true,
		["bg_b"] = 0.0941176470588235,
		["toolbar_side"] = 1,
		["bg_g"] = 0.0941176470588235,
		["desaturated_menu"] = true,
		["wallpaper"] = {
			["enabled"] = false,
			["texcoord"] = {
				0, -- [1]
				1, -- [2]
				0, -- [3]
				0.7, -- [4]
			},
			["overlay"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["anchor"] = "all",
			["height"] = 114.042518615723,
			["alpha"] = 0.5,
			["width"] = 283.000183105469,
		},
		["stretch_button_side"] = 1,
		["attribute_text"] = {
			["enabled"] = true,
			["shadow"] = true,
			["side"] = 1,
			["text_size"] = 16,
			["custom_text"] = "{name}",
			["text_face"] = "ITCAvantGardeStd-Demi",
			["anchor"] = {
				-19, -- [1]
				12, -- [2]
			},
			["text_color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["enable_custom_text"] = false,
			["show_timer"] = {
				true, -- [1]
				true, -- [2]
				true, -- [3]
			},
		},
		["bars_sort_direction"] = 1,
	},
}

_detalhes.skins["RefineUI"] = skinTable

local lower_instance = _detalhes:GetLowerInstanceNumber()
if lower_instance then
	for i = lower_instance, #_detalhes.tabela_instancias do
		local instance = Details:GetInstance(i)
		if instance and instance.rows_fit_in_window then
			for j = 1, instance.rows_fit_in_window do
				local bar = _G["DetailsBarra_Statusbar_"..i.."_"..j]
				local icon = _G["DetailsBarra_IconFrame_"..i.."_"..j]
				if bar and not bar.backdrop then
					bar:CreateBackdrop("Transparent")
					bar.backdrop:SetPoint("TOPLEFT", icon, -3, 3)

					bar.bg = bar:CreateTexture(nil, "BORDER")
					bar.bg:SetAllPoints(bar)
					bar.bg:SetTexture(C.media.texture)
					bar.bg:SetVertexColor(.6, .6, .6, 0.25)
				end
			end

			local frame = _G["DetailsUpFrameInstance"..i]
			frame.b = CreateFrame("Frame", nil, frame:GetParent())
			frame.b:SetTemplate("Overlay")
			frame.b:SetPoint("TOPLEFT", frame, "TOPLEFT", -24, 15)
			frame.b:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 35, 6)
			frame.b:SetFrameLevel(frame:GetFrameLevel() - 1)

			instance:ChangeSkin("RefineUI")
		end
	end
end

hooksecurefunc(Details, "ApplyProfile", function()
    C_Timer.After(0.5, UpdateDetailsPosition)
end)