local wezterm = require 'wezterm'
local actions = wezterm.action
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Actual config
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.75

config.color_scheme = 'Builtin Dark'
config.colors = {
	foreground    = '#E3E3EA',
	background    = '#000B1C',
	cursor_bg     = '#FFFFFF',
	cursor_fg     = '#000000',
	cursor_border = '#7FD4FF',
	selection_fg  = '#000000',
	selection_bg  = '#99CCFF',
}

-- config.default_cursor_style  = 'BlinkingBar'
-- config.cursor_blink_ease_in  = 'Constant'
-- config.cursor_blink_ease_out = 'Constant'

config.keys = {
	-- Navigation
	{ key = "LeftArrow",  mods="CTRL", action=actions.ActivateTabRelative(-1)},
	{ key = "RightArrow", mods="CTRL", action=actions.ActivateTabRelative(1)},
	{ key = "PageUp",     mods="CTRL", action=actions.ScrollByPage(-1) },
	{ key = "PageDown",   mods="CTRL", action=actions.ScrollByPage(1) },
	{ key = "UpArrow",    mods="CTRL", action=actions.ScrollByLine(-1), },
	{ key = "DownArrow",  mods="CTRL", action=actions.ScrollByLine(1), },
	-- Plane Controls
	{
		key    = "Escape",
		mods   = "CTRL",
		action = actions.CloseCurrentPane { confirm = true }
	},
	{ 
		key  = "RightArrow", 
		mods = "CTRL|SHIFT", 
		action=actions.SplitHorizontal{ domain = 'CurrentPaneDomain' }
	},
	{
		key    = "DownArrow",
		mods   = "CTRL|SHIFT",
		action = actions.SplitVertical{ domain = 'CurrentPaneDomain' }
	}
}

-- Config End
return config
