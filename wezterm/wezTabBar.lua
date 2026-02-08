local wezterm = require("wezterm")
local module = {}

local function get_current_dir(pane)
	local cwd = pane.current_working_dir
	if cwd then
		local path = cwd.file_path
		local decoded_path = path:gsub("file://[^/]*", "")
		local name = decoded_path:gsub("(.*[/\\])(.*)", "%2")
		return name ~= "" and name or decoded_path
	end
	return nil
end

local is_in_tmux = function(tab)
	local process_name = tab.active_pane.foreground_process_name:lower()
	if process_name:find("tmux") then
		return true
	end
	return false
end

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
		local pink = "#CBA6F7"
		local skyblue = "#7FFFD4"

		local base_color = is_in_tmux(tab) and skyblue or pink

		local background = "#181825"
		local foreground = base_color
		local edge_background = "none"

		if tab.is_active then
			background = base_color
			foreground = "#11111B"
		end

		local edge_foreground = background
		local current_dir = get_current_dir(tab.active_pane)
		local title = tab.active_pane.title
		local display_text = ""

		if current_dir then
			display_text = current_dir
		else
			display_text = title
		end
		display_text = "   " .. display_text .. "   "

		return {
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = SOLID_LEFT_ARROW },
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = display_text },
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			{ Text = SOLID_RIGHT_ARROW },
		}
	end)
end

return module
