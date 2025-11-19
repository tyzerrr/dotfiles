local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
    config.font = wezterm.font("JetBrains Mono", { weight = "Medium", stretch = "Normal", style = "Normal" })
end

return module
