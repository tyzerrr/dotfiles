return function()
    return require("lspconfig").util.root_pattern('package.json')(vim.fn.getcwd())
end
