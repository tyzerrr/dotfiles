return {
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            local ensure_installed = { "ts_ls", "lua_ls", "pyright", "gopls", "terraformls" }
            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = ensure_installed,
            })
        end,
        dependencies = {
            {
                "neovim/nvim-lspconfig",
                dependencies = {
                    "saghen/blink.cmp",
                },
                config = function()
                    require("lspconfig")
                end,
            },
            {
                "williamboman/mason.nvim",
                config = function()
                    require("mason").setup()
                end,
            },
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            }, }
    },

}
