-- lua/plugins/harpoon.lua
return {
    'theprimeagen/harpoon',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        vim.keymap.set("n", "<leader>a", function() require("harpoon.mark").add_file() end,
            { desc = "[A]dd file to Harpoon" })
        vim.keymap.set("n", "<C-e>", function() require("harpoon.ui").toggle_quick_menu() end,
            { desc = "Harpoon Quick Menu" })
        vim.keymap.set("n", "<leader>1", function() require("harpoon.ui").nav_file(1) end,
            { desc = "Harpoon Navigate to File 1" })
        vim.keymap.set("n", "<leader>2", function() require("harpoon.ui").nav_file(2) end,
            { desc = "Harpoon Navigate to File 2" })
        vim.keymap.set("n", "<leader>3", function() require("harpoon.ui").nav_file(3) end,
            { desc = "Harpoon Navigate to File 3" })
        vim.keymap.set("n", "<leader>4", function() require("harpoon.ui").nav_file(4) end,
            { desc = "Harpoon Navigate to File 4" })
    end,
}
