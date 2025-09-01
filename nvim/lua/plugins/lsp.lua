return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",

		config = function()
			local ensure_installed = { "ts_ls", "lua_ls", "pyright", "gopls", "terraformls" }
			require("mason-lspconfig").setup({
				automatic_installation = true,
				ensure_installed = ensure_installed,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"saghen/blink.cmp",
		},
		config = function()
			require("lspconfig")
		end,
	},
}
