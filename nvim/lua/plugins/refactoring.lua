return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	lazy = false,
	opts = {},
	config = function()
		local refactoring = require("refactoring")
		refactoring.setup({
			vim.keymap.set("n", "<leader>rp", function()
				refactoring.debug.printf({ below = false })
			end),
			vim.keymap.set({ "n", "x" }, "<leader>rv", function()
				refactoring.debug.print_var()
			end),
			vim.keymap.set({ "n", "x" }, "<leader>rc", function()
				refactoring.debug.cleanup()
			end),
		})
	end,
}
