-- lua/plugins/lualine.lua
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- アイコン用 (任意)
	event = "VeryLazy", -- 起動完了後にロード
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				-- theme = 'tokyonight', -- 使っているカラースキームに合わせる
				theme = "rose-pine", -- 使っているカラースキームに合わせる
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				-- ... 他の lualine オプション
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", { "diagnostics", sources = { "nvim_diagnostic" } } },
				lualine_c = { { "filename", path = 1 } }, -- path=1: relative path
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			-- ... 他のセクション設定
		})
	end,
}
