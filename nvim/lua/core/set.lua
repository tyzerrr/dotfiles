vim.opt.autoread = true
vim.opt.nu = true
vim.opt.rnu = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
-- fzf-lua等のfloating terminalでカーソルが点滅するのを止める。
-- nvimデフォルトのguicursorはターミナルモード(t)にblinkon500が入っているため上書きする。
vim.opt.guicursor:append("t:block-blinkon0")
vim.opt.errorbells = false
vim.opt.visualbell = true
vim.g.mapleader = " "
vim.g.laststatus = 2
