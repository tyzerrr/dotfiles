local find_python_path = function()
	-- activate 済み venv を最優先
	local venv = os.getenv("VIRTUAL_ENV")
	if venv then
		return venv .. "/bin/python"
	end
	-- プロジェクト直下の .venv / venv のインタプリタを探す
	local cwd = vim.fn.getcwd()
	for _, name in ipairs({ ".venv", "venv" }) do
		local py = cwd .. "/" .. name .. "/bin/python"
		if vim.fn.executable(py) == 1 then
			return py
		end
	end
	-- 見つからなければ PATH の python3
	return vim.fn.exepath("python3")
end

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

				if server_name == "lua_ls" then
					config.settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
								checkThirdParty = false,
							},
						},
					}
				end
				if server_name == "pyright" then
					config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
						python = { pythonPath = find_python_path() },
					})
				end
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
