return {
    {
        'echasnovski/mini.comment',
        event = "VeryLazy", -- 実際にコメント操作するまでロードしない
        config = function()
            require('mini.comment').setup({
                -- options = { custom_commentstring = ... } -- 必要なら設定
            })
        end
    },
}
