local menu_height= 300
local menu_width= 250
local menu_x= {
	[PLAYER_1]= _screen.w * .25,
	[PLAYER_2]= _screen.w * .75,
}
local menus= {}
for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
	menus[pn]= setmetatable({}, nesty_menu_stack_mt)
end
local explanations= {}
local ready_indicators= {}

local notefield_config= {
	nesty_options.float_config_val(newfield_prefs_config, "hidden_offset", -1, 1, 2),
	nesty_options.float_config_val(newfield_prefs_config, "sudden_offset", -1, 1, 2),
	nesty_options.bool_config_val(newfield_prefs_config, "hidden"),
	nesty_options.bool_config_val(newfield_prefs_config, "sudden"),
	nesty_options.float_config_val(newfield_prefs_config, "fade_dist", -1, 1, 2),
	nesty_options.bool_config_val(newfield_prefs_config, "glow_during_fade"),
	nesty_options.float_config_val(newfield_prefs_config, "reverse", -2, 0, 0),
	nesty_options.float_config_val(newfield_prefs_config, "zoom", -2, -1, 1),
	nesty_options.float_config_val(newfield_prefs_config, "rotation_x", -1, 1, 2),
	nesty_options.float_config_val(newfield_prefs_config, "rotation_y", -1, 1, 2),
	nesty_options.float_config_val(newfield_prefs_config, "rotation_z", -1, 1, 2),
	nesty_options.float_config_val(newfield_prefs_config, "vanish_x", -1, 1, 2),
	nesty_options.float_config_val(newfield_prefs_config, "vanish_y", -1, 1, 2),
	nesty_options.float_config_val(newfield_prefs_config, "fov", -1, 0, 1, 1, 179),
	nesty_options.float_config_val(newfield_prefs_config, "yoffset", -1, 1, 2),
	nesty_options.float_config_val(newfield_prefs_config, "zoom_x", -2, -1, 1),
	nesty_options.float_config_val(newfield_prefs_config, "zoom_y", -2, -1, 1),
	nesty_options.float_config_val(newfield_prefs_config, "zoom_z", -2, -1, 1),
}

local function gen_speed_menu(pn)
	local prefs= newfield_prefs_config:get_data(pn)
	if prefs.speed_type == "multiple" then
		return nesty_options.float_config_val_args(newfield_prefs_config, "speed_mod", -2, -1, 1)
	else
		return nesty_options.float_config_val_args(newfield_prefs_config, "speed_mod", -2, 1, 3)
	end
end

local function trisign_of_num(num)
	if num < 0 then return -1 end
	if num > 0 then return 1 end
	return 0
end

-- Skew needs to shift towards the center of the screen.
local pn_skew_mult= {[PLAYER_1]= 1, [PLAYER_2]= -1}

local function perspective_entry(name, skew_mult, rot_mult)
	return {
		name= name, meta= "execute", translatable= true,
		execute= function(pn)
			local conf_data= newfield_prefs_config:get_data(pn)
			local old_rot= get_element_by_path(conf_data, "rotation_x")
			local old_skew= get_element_by_path(conf_data, "vanish_x")
			local new_rot= rot_mult * 30
			local new_skew= skew_mult * 160 * pn_skew_mult[pn]
			set_element_by_path(conf_data, "rotation_x", new_rot)
			set_element_by_path(conf_data, "vanish_x", new_skew)
			-- Adjust the y offset to make the receptors appear at the same final
			-- position on the screen.
			if new_rot < 0 then
				set_element_by_path(conf_data, "yoffset", 180)
			elseif new_rot > 0 then
				set_element_by_path(conf_data, "yoffset", 140)
			else
				set_element_by_path(conf_data, "yoffset", get_element_by_path(newfield_prefs_config:get_default(), "yoffset"))
			end
			MESSAGEMAN:Broadcast("ConfigValueChanged", {
				config_name= newfield_prefs_config.name, field_name= "rotation_x", value= new_rot, pn= pn})
		end,
		underline= function(pn)
			local conf_data= newfield_prefs_config:get_data(pn)
			local old_rot= get_element_by_path(conf_data, "rotation_x")
			local old_skew= get_element_by_path(conf_data, "vanish_x")
			if trisign_of_num(old_rot) == trisign_of_num(rot_mult) and
			trisign_of_num(old_skew) == trisign_of_num(skew_mult) * pn_skew_mult[pn] then
				return true
			end
			return false
		end,
	}
end

local perspective_mods= {
	perspective_entry("overhead", 0, 0),
	perspective_entry("distant", 0, -1),
	perspective_entry("hallway", 0, 1),
	perspective_entry("incoming", 1, -1),
	perspective_entry("space", 1, 1),
}

local turn_chart_mods= {
	nesty_options.bool_player_mod_val("Mirror"),
	nesty_options.bool_player_mod_val("Backwards"),
	nesty_options.bool_player_mod_val("Left"),
	nesty_options.bool_player_mod_val("Right"),
	nesty_options.bool_player_mod_val("Shuffle"),
	nesty_options.bool_player_mod_val("SoftShuffle"),
	nesty_options.bool_player_mod_val("SuperShuffle"),
}

local removal_chart_mods= {
	nesty_options.bool_player_mod_val("NoHolds"),
	nesty_options.bool_player_mod_val("NoRolls"),
	nesty_options.bool_player_mod_val("NoMines"),
	nesty_options.bool_player_mod_val("HoldRolls"),
	nesty_options.bool_player_mod_val("NoJumps"),
	nesty_options.bool_player_mod_val("NoHands"),
	nesty_options.bool_player_mod_val("NoLifts"),
	nesty_options.bool_player_mod_val("NoFakes"),
	nesty_options.bool_player_mod_val("NoQuads"),
	nesty_options.bool_player_mod_val("NoStretch"),
}

local insertion_chart_mods= {
	nesty_options.bool_player_mod_val("Little"),
	nesty_options.bool_player_mod_val("Wide"),
	nesty_options.bool_player_mod_val("Big"),
	nesty_options.bool_player_mod_val("Quick"),
	nesty_options.bool_player_mod_val("BMRize"),
	nesty_options.bool_player_mod_val("Skippy"),
	nesty_options.bool_player_mod_val("Mines"),
	nesty_options.bool_player_mod_val("Echo"),
	nesty_options.bool_player_mod_val("Stomp"),
	nesty_options.bool_player_mod_val("Planted"),
	nesty_options.bool_player_mod_val("Floored"),
	nesty_options.bool_player_mod_val("Twister"),
}

local chart_mods= {
	{name= "turn_chart_mods", meta= nesty_option_menus.menu,
	 translatable= true, args= turn_chart_mods},
	{name= "removal_chart_mods", meta= nesty_option_menus.menu,
	 translatable= true, args= removal_chart_mods},
	{name= "insertion_chart_mods", meta= nesty_option_menus.menu,
	 translatable= true, args= insertion_chart_mods},
}

local NPSDisplayOptions= {
	nesty_options.bool_config_val(playerConfig, "NPSDisplay"),
	nesty_options.bool_config_val(playerConfig, "NPSGraph"),
	nesty_options.float_config_val(playerConfig, "NPSUpdateRate", -2, -1, -1, 0.01, 1),
	nesty_options.float_config_val(playerConfig, "NPSMaxVerts", 0, 1, 2, 10, 1000),
}

local ErrorBarOptions= {
	nesty_options.bool_config_val(playerConfig, "ErrorBar"),
	nesty_options.float_config_val(playerConfig, "ErrorBarDuration", -2, -1, 1, 0.1, 10),
	nesty_options.float_config_val(playerConfig, "ErrorBarMaxCount", 0, 1, 2, 1, 1000),
}

local LaneCoverOptions= {
	{name= "LaneCover", meta= nesty_option_menus.enum_option,
	 translatable= true,
	 args= {
		 name= "LaneCover", enum= {"Off", "Sudden+", "Hidden+"}, fake_enum= true,
		 obj_get= function(pn) return playerConfig:get_data(pn) end,
		 get= function(pn, obj) 
		 	local t = {"Off", "Sudden+", "Hidden+"}
		 	return t[obj.LaneCover+1] end,
		 set= function(pn, obj, value)
			if value == "Hidden+" then
				obj.LaneCover = 2
			elseif value == "Sudden+" then
				obj.LaneCover = 1
			else
				obj.LaneCover = 0
			end
		 end,
	}},
	nesty_options.float_config_val(playerConfig, "LaneCoverHeight", 0, 1, 2, -SCREEN_HEIGHT*2, SCREEN_HEIGHT*2),
	nesty_options.float_config_val(playerConfig, "LaneCoverLayer", 1, 1, 2, newfield_draw_order.under_explosions,newfield_draw_order.over_field),
}

local gameplay_options= {
	--nesty_options.bool_config_val(player_config, "ComboUnderField"),
	nesty_options.float_config_val(playerConfig, "ScreenFilter", -2, -1, 0, 0, 1),
	nesty_options.bool_config_val(playerConfig, "CBHighlight"),
	nesty_options.bool_config_val(playerConfig, "PaceMaker"),

	{name= "ErrorBarOptions", translatable= true, meta= nesty_option_menus.menu, args= ErrorBarOptions},
	{name= "LaneCoverOptions", translatable= true, meta= nesty_option_menus.menu, args= LaneCoverOptions},


	{name= "JudgeType", meta= nesty_option_menus.enum_option,
	 translatable= true,
	 args= {
		 name= "JudgeType", enum= {"Off", "No Highlights", "On"}, fake_enum= true,
		 obj_get= function(pn) return playerConfig:get_data(pn) end,
		 get= function(pn, obj) 
		 	local t = {"Off", "No Highlights", "On"}
		 	return t[obj.JudgeType+1] end,
		 set= function(pn, obj, value)
			if value == "Off" then
				obj.JudgeType = 0
			elseif value == "No Highlights" then
				obj.JudgeType = 1
			else
				obj.JudgeType = 2
			end
		 end,
	}},

	{name= "AvgScoreType", meta= nesty_option_menus.enum_option,
	 translatable= true,
	 args= {
		 name= "AvgScoreType", enum= {THEME:GetString('OptionNames','Off'), 'DP', '%Score', 'MIGS'}, fake_enum= true,
		 obj_get= function(pn) return playerConfig:get_data(pn) end,
		 get= function(pn, obj) 
		 	local t = {THEME:GetString('OptionNames','Off'), 'DP', '%Score', 'MIGS'}
		 	return t[obj.AvgScoreType+1] end,
		 set= function(pn, obj, value)
			if value == "DP" then
				obj.AvgScoreType = 1
			elseif value == "%Score" then
				obj.AvgScoreType = 2
			elseif value == "MIGS" then
				obj.AvgScoreType = 3
			else
				obj.AvgScoreType = 0
			end;
		 end,
	}},

	{name= "GhostScoreType", meta= nesty_option_menus.enum_option,
	 translatable= true,
	 args= {
		 name= "GhostScoreType", enum= {THEME:GetString('OptionNames','Off'), 'DP', '%Score', 'MIGS'}, fake_enum= true,
		 obj_get= function(pn) return playerConfig:get_data(pn) end,
		 get= function(pn, obj) 
		 	local t = {THEME:GetString('OptionNames','Off'), 'DP', '%Score', 'MIGS'}
		 	return t[obj.GhostScoreType+1] end,
		 set= function(pn, obj, value)
			if value == "DP" then
				obj.GhostScoreType = 1
			elseif value == "%Score" then
				obj.GhostScoreType = 2
			elseif value == "MIGS" then
				obj.GhostScoreType = 3
			else
				obj.GhostScoreType = 0
			end;
		 end,
	}},

	nesty_options.float_config_val(playerConfig, "GhostTarget", -2, 1, 1, 0, 100),
	{name= "NPSDisplayOptions", translatable= true, meta= nesty_option_menus.menu, args= NPSDisplayOptions},
	
}

local base_options= {
	{name= "speed_mod", meta= nesty_option_menus.adjustable_float,
	 translatable= true, args= gen_speed_menu, exec_args= true},
	{name= "speed_type", meta= nesty_option_menus.enum_option,
	 translatable= true,
	 args= {
		 name= "speed_type", enum= newfield_speed_types, fake_enum= true,
		 obj_get= function(pn) return newfield_prefs_config:get_data(pn) end,
		 get= function(pn, obj) return obj.speed_type end,
		 set= function(pn, obj, value)
			 if obj.speed_type == "multiple" and value ~= "multiple" then
				 obj.speed_mod= math.round(obj.speed_mod * 100)
			 elseif obj.speed_type ~= "multiple" and value == "multiple" then
				 obj.speed_mod= obj.speed_mod / 100
			 end
			 obj.speed_type= value
			 newfield_prefs_config:set_dirty(pn)
			 MESSAGEMAN:Broadcast("ConfigValueChanged", {
				config_name= newfield_prefs_config.name, field_name= "speed_type", value= value, pn= pn})
		 end,
	}},
	nesty_options.float_song_mod_val("MusicRate", -2, -1, -1, .5, 2, 1),
	nesty_options.float_song_mod_toggle_val("Haste", 1, 0),
	{name= "perspective", translatable= true, meta= nesty_option_menus.menu, args= perspective_mods},
	nesty_options.float_config_toggle_val(newfield_prefs_config, "reverse", -1, 1),
	nesty_options.float_config_val(newfield_prefs_config, "zoom", -2, -1, 1),
	{name= "chart_mods", translatable= true, meta= nesty_option_menus.menu, args= chart_mods},
	{name= "newskin", translatable= true, meta= nesty_option_menus.newskins},
	{name= "newskin_params", translatable= true, meta= nesty_option_menus.menu,
	 args= gen_noteskin_param_menu, req_func= show_noteskin_param_menu},
	nesty_options.bool_config_val(newfield_prefs_config, "hidden"),
	nesty_options.bool_config_val(newfield_prefs_config, "sudden"),
	{name= "advanced_notefield_config", translatable= true, meta= nesty_option_menus.menu, args= notefield_config},
	{name= "gameplay_options", translatable= true, meta= nesty_option_menus.menu, args= gameplay_options},
	{name= "reload_newskins", translatable= true, meta= "execute",
	 execute= function() NEWSKIN:reload_skins() end},
}

local player_ready= {}

local function exit_if_both_ready()
	for i, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
		if not player_ready[pn] then return end
	end
	SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen")
end

local prev_explanation= {}
local function update_explanation(pn)
	local cursor_item= menus[pn]:get_cursor_item()
	if cursor_item then
		local new_expl= cursor_item.name or cursor_item.text
		local expl_com= "change_explanation"
		if cursor_item.explanation then
			new_expl= cursor_item.explanation
			expl_com= "translated_explanation"
		end
		if new_expl ~= prev_explanation[pn] then
			prev_explanation[pn]= new_expl
			explanations[pn]:playcommand(expl_com, {text= new_expl})
		end
	end
end

local function input(event)
	local pn= event.PlayerNumber
	if not pn then return end
	if menu_stack_generic_input(menus, event) then
		player_ready[pn]= true
		ready_indicators[pn]:playcommand("show_ready")
		exit_if_both_ready()
	else
		if player_ready[pn] and not menus[pn]:can_exit_screen() then
			player_ready[pn]= false
			ready_indicators[pn]:playcommand("hide_ready")
		elseif event.GameButton == "Back" and GAMESTATE:IsHumanPlayer(pn) then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToPrevScreen")
		end
	end
	update_explanation(pn)
end

local menu_item_mt= DeepCopy(option_item_underlinable_mt)
menu_item_mt.__index.text_style_init= function(text_actor)
	text_actor:shadowlength(1)
end

local frame= Def.ActorFrame{
	OnCommand= function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
		for pn, menu in pairs(menus) do
			menu:push_options_set_stack(nesty_option_menus.menu, base_options, "play_song")
			menu:update_cursor_pos()
			update_explanation(pn)
		end
	end,
}
for pn, menu in pairs(menus) do
	frame[#frame+1]= LoadActor(
		THEME:GetPathG("ScreenOptions", "halfpage")) .. {
		InitCommand= function(self)
			self:xy(menu_x[pn], 250)
		end
	}
	frame[#frame+1]= menu:create_actors{
		x= menu_x[pn], y= 96, width= menu_width, height= menu_height,
		num_displays= 1, pn= pn, item_mt= menu_item_mt,
		el_height= 20, zoom= .55,
	}
	menu:set_translation_section("newfield_options")
	frame[#frame+1]= Def.BitmapText{
		Font= "Common Normal", InitCommand= function(self)
			explanations[pn]= self
			self:xy(menu_x[pn] - (menu_width / 2), _screen.cy+174)
				:diffuse(PlayerColor(pn))
				:shadowlength(1):wrapwidthpixels(menu_width / .5):zoom(.5)
				:horizalign(left)
		end,
		change_explanationCommand= function(self, param)
			local text= ""
			if THEME:HasString("newfield_explanations", param.text) then
				text= THEME:GetString("newfield_explanations", param.text)
			end
			self:playcommand("translated_explanation", {text= text})
		end,
		translated_explanationCommand= function(self, param)
			self:stoptweening():settext(param.text):cropright(1):linear(.5):cropright(0)
		end,
	}
	frame[#frame+1]= Def.BitmapText{
		Font= "Common Normal", Text= "READY!", InitCommand= function(self)
			ready_indicators[pn]= self
			self:xy(menu_x[pn], 106):zoom(1.5):diffuse(Color.Green):diffusealpha(0)
		end,
		show_readyCommand= function(self)
			self:stoptweening():decelerate(.5):diffusealpha(1)
		end,
		hide_readyCommand= function(self)
			self:stoptweening():accelerate(.5):diffusealpha(0)
		end,
	}

end

frame[#frame+1] = LoadActor("ScreenPlayerOptions avatars")



return frame
