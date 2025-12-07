return {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- or if using mini.icons/mini.nvim
    -- dependencies = { "nvim-mini/mini.icons" },
    ---@module "fzf-lua"
    ---@type fzf-lua.Config|{}
    ---@diagnostics disable: missing-fields
    keys = {
        { "<leader>pf",  "<cmd>FzfLua files<cr>",               desc = "Find files" },
        { "<leader>ps",  "<cmd>FzfLua live_grep<cr>",           desc = "Search in files" },
        { "<leader>gf",  "<cmd>FzfLua git_files<cr>",           desc = "Git files" },
        { "<leader>gd",  "<cmd>FzfLua git_diff<cr>",            desc = "Git diff" },
        { "<leader>gs",  "<cmd>FzfLua git_status<cr>",          desc = "Git status" },
        { "<leader>gb",  "<cmd>FzfLua git_branches<cr>",        desc = "Git branches" },
        { "gr",          "<cmd>FzfLua lsp_references<cr>",      desc = "LSP references" },
        { "gd",          "<cmd>FzfLua lsp_definitions<cr>",     desc = "LSP definitions" },
        { "gI",          "<cmd>FzfLua lsp_implementations<cr>", desc = "LSP implementations" },
        { "<leader>lca", "<cmd>FzfLua lsp_code_actions<cr>",    desc = "LSP code actions" },
    },
    opts = {
    }
}
