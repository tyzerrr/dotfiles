-- lua/plugins/clipper.lua
return {
    "TlexCypher/clipper.nvim",
    lazy = false,
    cmd = "Clipper",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<leader>cc", "<cmd>Clipper<cr>" }
    },
    config = function()
        require("clipper").setup()
    end
}
