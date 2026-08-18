return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- optional but recommended
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		require("telescope").setup({})
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
		vim.keymap.set("n", "<C-p>", builtin.git_files, {})
		vim.keymap.set("n", "<leader>ps", function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end, {})
		vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
		-- vscode-neovim has no Neovim-side LSP client.  Keep the mappings from
		-- core.remap.lua so Cursor can handle these with its native LSP.
		if not vim.g.vscode then
			vim.keymap.set("n", "gd", builtin.lsp_definitions, {})
			vim.keymap.set("n", "gI", builtin.lsp_implementations, {})
			vim.keymap.set("n", "gr", builtin.lsp_references, {})
		end
	end,
}
