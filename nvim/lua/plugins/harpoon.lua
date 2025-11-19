-- lua/plugins/harpoon.lua
return {
    'theprimeagen/harpoon',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        vim.keymap.set("n", "<leader>a", function() require("harpoon.mark").add_file() end,
            { desc = "[A]dd file to Harpoon" })
        vim.keymap.set("n", "<C-e>", function() require("harpoon.ui").toggle_quick_menu() end,
            { desc = "Harpoon Quick Menu" })
    end,
}
