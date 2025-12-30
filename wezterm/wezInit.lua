local module = {}

function module.apply_to_config(config)
	config.scrollback_lines = 3500
	config.enable_scroll_bar = true
	config.macos_window_background_blur = 20
	config.window_decorations = "RESIZE"
end

return module
