return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("telescope").setup({
			pickers = {
				find_files = {
					hidden = true,
				},
			},
			defaults = {
				file_ignore_patterns = {
					"node_modules",
					"%.git",
					"%.DS_Store",
					"%.zip",
					"%.bin",
					"tar",
					"jar",
					"data",
					"doc",
					"LICENCE",
					"manifest",
				},
			},
		})
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
		vim.keymap.set("n", "<C-p>", builtin.git_files, {})
		vim.keymap.set("n", "<leader>ps", builtin.live_grep, {})
		vim.keymap.set("n", "gr", builtin.lsp_references, {})
		vim.keymap.set("n", "gd", builtin.lsp_definitions, {})
	end,
}
