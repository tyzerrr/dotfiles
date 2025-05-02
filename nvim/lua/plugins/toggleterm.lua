-- lua/plugins/toggleterm.lua
return {
    'akinsho/toggleterm.nvim',
    version = "*", -- 常に最新を使う場合
    config = function()
        require("toggleterm").setup({
            -- size = 20,
            open_mapping = [[<c-t>]], -- 例: Ctrl+T で開閉
            direction = 'float',
            -- float_opts = { border = 'curved' },
            -- 他の ToggleTerm オプション...
        })
    end,
}
