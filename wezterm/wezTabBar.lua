local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
	-- Title barの背景を透明にする
	config.window_frame = {
		inactive_titlebar_bg = "none",
		active_titlebar_bg = "none",
		font_size = 18.0,
	}

	config.use_fancy_tab_bar = true

	-- Tokyo Nightの背景色に合わせる
	config.window_background_gradient = {
		colors = { "#1a1b26" },
	}

	-- タブバーの新しいタブボタンを非表示にする
	config.show_new_tab_button_in_tab_bar = false

	-- タブ同士の境界線を消す
	config.colors = {
		tab_bar = {
			inactive_tab_edge = "none",
		},
	}

	local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
	local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle
	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		-- local pink = "#CBA6F7"
		local skyblue = "#7FFFD4"

		local background = "#181825"
		local foreground = skyblue
		local edge_background = "none"

		if tab.is_active then
			background = skyblue
			foreground = "#11111B"
		end
		local edge_foreground = background
		local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

		return {
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = title },
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = SOLID_RIGHT_ARROW },
		}
	end)
end

return module
