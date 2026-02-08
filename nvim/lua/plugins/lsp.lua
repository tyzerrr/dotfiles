return {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			{ "williamboman/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp",
		},
		config = function()
			require("mason").setup()

			local capabilities = {}
			local ok, blink = pcall(require, "blink.cmp")
			if ok then
				capabilities = blink.get_lsp_capabilities()
			end

			local servers = { "ts_ls", "lua_ls", "pyright", "gopls", "terraformls" }

			require("mason-lspconfig").setup({
				ensure_installed = servers,
			})

			for _, server_name in ipairs(servers) do
				local config = vim.lsp.config[server_name] or {}
				config.capabilities = vim.tbl_deep_extend("force", config.capabilities or {}, capabilities)
				vim.lsp.config[server_name] = config
				vim.lsp.enable(server_name)
			end

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})
		end,
	},
}
