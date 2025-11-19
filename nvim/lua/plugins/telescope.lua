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
                    "^.git/",
                    "^node_modules/",
                    "%.DS_Store",
                    "%.zip",
                    "%.bin",
                    "tar",
                    "jar",
                    "doc",
                    "LICENCE",
                    "manifest",
                },
            },
            extensions = {
                wrap_results = true,
                fzf = {
                    fuzzy = true,                   -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true,    -- override the file sorter
                    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                    -- the default case_mode is "smart_case"
                },
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown({}),
                },
            },
        })

        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
        vim.keymap.set("n", "<C-p>", builtin.git_files, {})
        vim.keymap.set("n", "<leader>ps", builtin.live_grep, {})
        vim.keymap.set("n", "gr", builtin.lsp_references, {})
        vim.keymap.set("n", "gd", builtin.lsp_definitions, {})
        vim.keymap.set("n", "<leader>sh", builtin.help_tags, {})
        vim.keymap.set("n", "gI", builtin.lsp_implementations, {})
        vim.keymap.set("n", "vca", vim.lsp.buf.code_action, {})

        require("telescope").load_extension("fzf")
        require("telescope").load_extension("ui-select")
    end,
}
