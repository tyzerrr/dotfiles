return {
    "nvimdev/dashboard-nvim",
    lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
    opts = function()
        local logo = [[
        ██████╗ ██████╗ ██╗███╗   ███╗███████╗   ██╗   ██╗██╗███╗   ███╗
        ██╔══██╗██╔══██╗██║████╗ ████║██╔════╝   ██║   ██║██║████╗ ████║
        ██████╔╝██████╔╝██║██╔████╔██║█████╗     ██║   ██║██║██╔████╔██║
        ██╔══╝  ██╔══██╗██║██║╚██╔╝██║██╔══╝     ╚██╗ ██╔╝██║██║╚██╔╝██║
        ██║     ██║  ██║██║██║ ╚═╝ ██║███████╗    ╚████╔╝ ██║██║ ╚═╝ ██║
        ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
    ]]

        logo = string.rep("\n", 8) .. logo .. "\n\n"

        local opts = {
            theme = "doom",
            hide = {
                -- this is taken care of by lualine
                -- enabling this messes up the actual laststatus setting after loading a file
                statusline = false,
            },
            config = {
                vim.fn.foldlevel(99),
                header = vim.split(logo, "\n"),
                -- stylua: ignore
                center = {
                    { action = 'lua Picker.pick("files")()', desc = " Find File", icon = " ", key = "f" },
                    { action = "ene | startinsert", desc = " New File", icon = " ", key = "n" },
                    { action = 'lua Picker.pick("oldfiles")()', desc = " Recent Files", icon = " ", key = "r" },
                    { action = 'lua Picker.pick("live_grep")()', desc = " Find Text", icon = " ", key = "g" },
                    { action = 'lua Picker.config_files()()', desc = " Config", icon = " ", key = "c" },
                    { action = 'lua Picker.dotfiles()()', desc = " Dot File", icon = " ", key = "d" },
                    { action = 'lua Picker.personal_projects()()', desc = " Personal Projects", icon = " ", key = "p" },
                    { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
                    { action = "Mason", desc = " Mason", icon = "󱛝 ", key = "m" },
                    { action = function() vim.api.nvim_input("<cmd>qa<cr>") end, desc = " Quit", icon = " ", key = "q" },
                },
                footer = function()
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    return {
                        "⚡ PrimeVim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
                    }
                end,
            },
        }

        for _, button in ipairs(opts.config.center) do
            button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
            button.key_format = "  %s"
        end

        -- open dashboard after closing lazy
        if vim.o.filetype == "lazy" then
            vim.api.nvim_create_autocmd("WinClosed", {
                pattern = tostring(vim.api.nvim_get_current_win()),
                once = true,
                callback = function()
                    vim.schedule(function()
                        vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
                    end)
                end,
            })
        end
        return opts
    end,
}
