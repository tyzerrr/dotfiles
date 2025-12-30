local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
	config.font = wezterm.font_with_fallback({
		{
			family = "JetBrains Mono",
			weight = "Medium",
			stretch = "Normal",
			style = "Normal",
		},
		{
			family = "Hiragino Kaku Gothic ProN",
			weight = "Regular",
			stretch = "Normal",
			style = "Normal",
		},
	})
	config.use_ime = true
end

return module
