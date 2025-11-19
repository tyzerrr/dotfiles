function ColorMyPencils(color)
    -- color = color or "vscode"
    -- color = color or "nord"
    -- color = color or "rose-pine"
    color = color or "tokyonight"
    -- color = color or "catppuccin"
    -- vim.cmd.colorscheme(color)
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
    {
        "folke/tokyonight.nvim",
        lazy = false,    -- 起動時にロード
        priority = 1000, -- 他のUIプラグインより先にロード
        config = function()
            vim.cmd.colorscheme "tokyonight"
            -- ColorMyPencils()
        end,
    },
    -- {
    -- 	"rose-pine/neovim",
    -- 	name = "rose-pine",
    -- 	-- enabled = false, -- デフォルトでは無効化しておく例
    -- 	lazy = false,
    -- 	priority = 1000,
    -- 	config = function()
    -- 		require("rose-pine").setup({
    -- 			styles = {
    -- 				italic = false,
    -- 			},
    -- 		})
    -- 		vim.cmd.colorscheme("rose-pine")
    -- 		ColorMyPencils()
    -- 	end,
    -- },

    -- {
    --     "folke/tokyonight.nvim",
    --     priority = 1000,
    --     config = function()
    --         local transparent = false -- set to true if you would like to enable transparency
    --
    --         local bg = "#011628"
    --         local bg_dark = "#011423"
    --         local bg_highlight = "#143652"
    --         local bg_search = "#0A64AC"
    --         local bg_visual = "#275378"
    --         local fg = "#CBE0F0"
    --         local fg_dark = "#B4D0E9"
    --         local fg_gutter = "#627E97"
    --         local border = "#547998"
    --
    --         require("tokyonight").setup({
    --             on_highlights = function(hl, c)
    --                 hl.CursorLineNr = { fg = c.orange, bold = true }
    --                 hl.DiagnosticHint = { fg = c.blue }
    --                 hl.DiagnosticHintUnderline = { fg = c.blue, undercurl = true }
    --             end,
    --             style = "night",
    --             transparent = transparent,
    --             styles = {
    --                 sidebars = transparent and "transparent" or "dark",
    --                 floats = transparent and "transparent" or "dark",
    --             },
    --             on_colors = function(colors)
    --                 colors.bg = bg
    --                 colors.bg_dark = transparent and colors.none or bg_dark
    --                 colors.bg_float = transparent and colors.none or bg_dark
    --                 colors.bg_highlight = bg_highlight
    --                 colors.bg_popup = bg_dark
    --                 colors.bg_search = bg_search
    --                 colors.bg_sidebar = transparent and colors.none or bg_dark
    --                 colors.bg_statusline = transparent and colors.none or bg_dark
    --                 colors.bg_visual = bg_visual
    --                 colors.border = border
    --                 colors.fg = fg
    --                 colors.fg_dark = fg_dark
    --                 colors.fg_float = fg
    --                 colors.fg_gutter = fg_gutter
    --                 colors.fg_sidebar = fg_dark
    --             end,
    --         })
    --
    --         vim.cmd("colorscheme tokyonight")
    --     end,
    -- }
}
