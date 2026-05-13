-- lua/plugins/treesitter.lua
local parsers = {
	"bash",
	"c",
	"cpp",
	"css",
	"go",
	"html",
	"java",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"rust",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
	"prisma",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})

			require("nvim-treesitter").install(parsers)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = parsers,
				callback = function()
					pcall(vim.treesitter.start)
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
}
