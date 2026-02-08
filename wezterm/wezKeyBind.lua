local wezterm = require("wezterm")
require("wezIncrementOpacity")
require("wezDecrementOpacity")
require("wezToggleOpacity")
local module = {}

function module.apply_to_config(config)
	config.disable_default_key_bindings = true
	config.leader = { key = "w", mods = "CTRL", timeout_milliseconds = 5000 }
	config.keys = {

		{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
		{
			key = "\\",
			mods = "LEADER",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "-",
			mods = "LEADER",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "w",
			mods = "CMD",
			action = wezterm.action.CloseCurrentPane({ confirm = true }),
		},
		{
			key = "h",
			mods = "LEADER",
			action = wezterm.action.ActivatePaneDirection("Left"),
		},
		{
			key = "j",
			mods = "LEADER",
			action = wezterm.action.ActivatePaneDirection("Down"),
		},
		{
			key = "k",
			mods = "LEADER",
			action = wezterm.action.ActivatePaneDirection("Up"),
		},
		{
			key = "l",
			mods = "LEADER",
			action = wezterm.action.ActivatePaneDirection("Right"),
		},
		{
			key = "f",
			mods = "LEADER",
			action = wezterm.action.ToggleFullScreen,
		},
		-- create new tab
		{
			key = "t",
			mods = "CMD",
			action = wezterm.action.SpawnTab("CurrentPaneDomain"),
		},
		-- change font size
		{
			key = "=",
			mods = "CMD",
			action = wezterm.action.IncreaseFontSize,
		},
		{
			key = "-",
			mods = "CMD",
			action = wezterm.action.DecreaseFontSize,
		},
		-- copy to clipboard
		{
			key = "v",
			mods = "CMD",
			action = wezterm.action.PasteFrom("Clipboard"),
		},
		-- change opacity
		{
			key = "t",
			mods = "LEADER",
			action = wezterm.action.EmitEvent("toggle_opacity"),
		},
		{
			key = "d",
			mods = "LEADER",
			action = wezterm.action.EmitEvent("incrementOpacity"),
		},
		{
			key = "u",
			mods = "LEADER",
			action = wezterm.action.EmitEvent("decrementOpacity"),
		},
		-- enter copy mode
		{
			key = "c",
			mods = "LEADER",
			action = wezterm.action.ActivateCopyMode,
		},
		-- search and find
		{
			key = "f",
			mods = "CMD",
			action = wezterm.action.Search({ CaseInSensitiveString = "" }),
		},
	}
	for i = 1, 9 do
		table.insert(config.keys, {
			key = tostring(i),
			mods = "LEADER",
			action = wezterm.action.ActivateTab(i - 1),
		})
	end
end

return module
