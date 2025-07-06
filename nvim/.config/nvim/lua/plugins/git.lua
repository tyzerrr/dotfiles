-- lua/plugins/git.lua
return {
    -- Lazygit
    {
        "kdheepak/lazygit.nvim",
        cmd = "LazyGit", -- コマンドでロード
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = { { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
    },

    -- Diffview
    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>do", "<cmd>DiffviewOpen<cr>",  desc = "Diffview Open" },
            { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
        },
    },
}
