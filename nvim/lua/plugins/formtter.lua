return {
	"stevearc/conform.nvim",
	config = function()
		local lua_fmts = { "stylua" }
		local go_fmts = { "gofumpt", "goimports" }
		local js_fmts = { "prettier" }
		local python_fmts = { "isort", "black" }

		require("conform").setup({
			formatters_by_ft = {
				lua = lua_fmts,
				go = go_fmts,
				javascript = js_fmts,
				python = python_fmts,
			},
			format_on_save = {
				timeout_ms = 5000,
				lsp_fallback = true,
				quiet = false,
			},
		})
	end,
	opts = {},
}
