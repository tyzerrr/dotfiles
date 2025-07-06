-- lua/plugins/autopairs.lua
return {
    'windwp/nvim-autopairs',
    event = "InsertEnter", -- Insertモードに入ったらロード
    config = function()
        require('nvim-autopairs').setup({
            -- check_ts = true, -- treesitter と連携する場合
            -- ts_config = { ... },
            -- map_cr = true, -- <CR> の挙動を賢くする場合
        })
        -- (任意) CMPとの連携 (CMPの設定ファイルでも設定可能)
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        local cmp = require('cmp')
        if cmp then
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end
    end
}
