-- ユーザー設定全体(lazy.nvim等)を読み込まず、テスト対象のモジュールとplenaryだけをruntimepathに載せる。
local config_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local lazy_dir = vim.fn.stdpath("data") .. "/lazy"

-- providerがstdpath("state")にセッションファイルを作るため、実環境の状態ディレクトリを汚さない
vim.env.XDG_STATE_HOME = vim.fn.tempname()

vim.opt.runtimepath:prepend(config_dir)
vim.opt.runtimepath:append(lazy_dir .. "/plenary.nvim")
-- providerがコマンド文字列の分割にclaudecode.utilsを使うため
vim.opt.runtimepath:append(lazy_dir .. "/claudecode.nvim")
vim.opt.swapfile = false

vim.cmd("runtime plugin/plenary.vim")
