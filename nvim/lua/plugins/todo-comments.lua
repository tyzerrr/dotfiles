return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("todo-comments").setup({
        })
        vim.keymap.set("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "Todo (Trouble)" })
        vim.keymap.set("n", "<leader>fT", "<cmd>TodoTelescope<cr>", { desc = "Find Todos (Telescope)" })
    end,
}
