-- lua/plugins/trouble.lua
--
return {
    "folke/trouble.nvim",
    opts = {
        use_diagnostic_signs = true,
    }, -- for default options, refer to the configuration section for custom setup.
    lazy = false,
    config = function()
        ---@function modeOpts
        ---@param mode string
        ---@return table
        local modeOpts = function(mode)
            return {
                mode = mode,
                win = {
                    type = "split",
                    position = "right",
                }
            }
        end

        require("trouble").setup()

        local diagnostics = modeOpts("diagnostics")
        local quickfix = modeOpts("quickfix")

        --diagnostics
        vim.keymap.set("n", "<leader>xx", function()
            require("trouble").toggle(diagnostics)
        end)

        vim.keymap.set("n", "<leader>xn", function()
            require("trouble").next(diagnostics, {})
        end)


        vim.keymap.set("n", "<leader>xp", function()
            require("trouble").prev(diagnostics, {})
        end)

        ---quickfix
        vim.keymap.set("n", "<leader>qf", function()
            require("trouble").toggle(quickfix)
        end)
        vim.keymap.set("n", "<leader>qn", function()
            require("trouble").next(quickfix, {})
        end)

        vim.keymap.set("n", "<leader>qp", function()
            require("trouble").prev(quickfix, {})
        end)
    end
}
