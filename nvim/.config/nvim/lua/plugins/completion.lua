-- lua/plugins/completion.lua
return {
	-- Snippet Engine: LuaSnip
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" },
		config = function()
			-- VSCodeライクなスニペットをロード
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"onsails/lspkind.nvim",
	},
	-- Completion Engine: nvim-cmp
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" }, -- Insertモード or コマンドラインでロード
		dependencies = {
			"hrsh7th/cmp-buffer", -- Buffer source
			"hrsh7th/cmp-path", -- Path source
			"hrsh7th/cmp-nvim-lsp", -- LSP source
			"hrsh7th/cmp-nvim-lua", -- Lua API source (Neovim config用)
			"saadparwaiz1/cmp_luasnip", -- Snippet source
			-- "hrsh7th/cmp-cmdline",       -- (任意) コマンドライン補完用
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-k>"] = cmp.mapping.select_prev_item(cmp.SelectBehavior.Insert),
					["<C-j>"] = cmp.mapping.select_next_item(cmp.SelectBehavior.Insert),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- 重要: Select=true で選択候補を確定
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),

				formatting = {
					format = function(entry, item)
						local icons = require("utils.icons").kinds
						if icons[item.kind] then
							item.kind = icons[item.kind] .. item.kind
						end

						local widths = {
							abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
							menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
						}

						for key, width in pairs(widths) do
							if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
								item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
							end
						end

						return item
					end,
				},
			})
		end,
	},
}
