local wezterm = require("wezterm")
local actions = wezterm.action
local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Actual config
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.75

-- Temporary Fix for Hyprland
if os.getenv("XDG_CURRENT_DESKTOP") == "Hyprland" then
	config.enable_wayland = false
else
	config.enable_wayland = true
end

-- Custom Wallust ColorScheme
config.color_scheme = "Wallust"

-- config.default_cursor_style  = 'BlinkingBar'
-- config.cursor_blink_ease_in  = 'Constant'
-- config.cursor_blink_ease_out = 'Constant'

config.keys = {
	-- Navigation
	{ key = "LeftArrow",  mods = "CTRL|ALT", action = actions.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "CTRL|ALT", action = actions.ActivateTabRelative(1) },
	{ key = "PageUp",     mods = "ALT",      action = actions.ScrollByPage(-1) },
	{ key = "PageDown",   mods = "ALT",      action = actions.ScrollByPage(1) },
	{ key = "UpArrow",    mods = "ALT",      action = actions.ScrollByLine(-1) },
	{ key = "DownArrow",  mods = "ALT",      action = actions.ScrollByLine(1) },
	-- Plane Controls
	{
		key = "Escape",
		mods = "CTRL|ALT",
		action = actions.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "RightArrow",
		mods = "SHIFT|ALT",
		action = actions.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "DownArrow",
		mods = "SHIFT|ALT",
		action = actions.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
}

-- Config End
return config
