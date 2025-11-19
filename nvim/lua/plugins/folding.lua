return {
	"kevinhwang91/nvim-ufo",
	event = "VeryLazy",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	config = function()
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true
		vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
		vim.keymap.set("n", "zp", require("ufo").peekFoldedLinesUnderCursor)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "neo-tree" },
			group = vim.api.nvim_create_augroup("tlexcypher-text-folding", { clear = true }),
			callback = function()
				require("ufo").detach()
				vim.opt_local.foldenable = false
			end,
		})
		require("ufo").setup({
			provider_selector = function(_, _, _)
				return { "treesitter", "indent" }
			end,
		})
	end,
}
