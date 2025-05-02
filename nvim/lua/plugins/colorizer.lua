-- lua/plugins/colorizer.lua
return {
  'norcalli/nvim-colorizer.lua',
  event = "BufReadPost", -- バッファ読み込み後にロード
  config = function()
    require('colorizer').setup({
      -- filetypes = { '*' }, -- 全ファイルタイプで有効化する場合
      -- user_default_options = { mode = 'background', ... } -- オプション設定
    })
  end
}
