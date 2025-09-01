function ColorMyPencils(color)
	-- color = color or "vscode"
	-- color = color or "nord"
	-- color = color or "rose-pine"
	color = color or "tokyonight"
	-- color = color or "catppuccin"
	-- vim.cmd.colorscheme(color)
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
	-- {
	--   "folke/tokyonight.nvim",
	--   lazy = false, -- 起動時にロード
	--   priority = 1000, -- 他のUIプラグインより先にロード
	--   config = function()
	--     vim.cmd.colorscheme "tokyonight"
	--     ColorMyPencils()
	--   end,
	-- },
	{
		"rose-pine/neovim",
		name = "rose-pine",
		-- enabled = false, -- デフォルトでは無効化しておく例
		lazy = false,
		priority = 1000,
		config = function()
			require("rose-pine").setup({
				styles = {
					italic = false,
				},
			})
			vim.cmd.colorscheme("rose-pine")
			ColorMyPencils()
		end,
	},
}
