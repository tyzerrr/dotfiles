-- lua/lsp/ directory is for overwriting each specific language server setting with lua/lsp/<language server name>.lua.
-- This file is the entry point for general lsp settings.
vim.lsp.enable(require("mason-lspconfig").get_installed_servers())
vim.diagnostic.config({
    virtual_text = true,
})
