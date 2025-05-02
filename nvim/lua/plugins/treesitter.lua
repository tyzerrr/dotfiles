-- lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          "bash", "c", "cpp", "css", "go", "html", "java", "javascript",
          "json", "lua", "markdown", "markdown_inline", "python",
          "query", "rust", "typescript", "vim", "vimdoc", "yaml"
          -- 必要に応じて追加・削除
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        -- context_commentstring = { enable = true, enable_autocmd = false }, -- コメントアウト支援
      })
    end,
  },
  {
    -- Treesitter Playground (任意)
    'nvim-treesitter/playground',
    cmd = "TSPlaygroundToggle", -- コマンド実行時にロード
  },
}
