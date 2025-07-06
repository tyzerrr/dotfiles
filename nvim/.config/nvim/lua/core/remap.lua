vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

--auto indenting and move multiple lines.
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- remain cursor to same place
vim.keymap.set("n", "J", "mzJ`z")

--search and fix cursor into center of screen.
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

--greatest remap ever
vim.keymap.set("x", "<leader>p", "\"_dP")

--yank to clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("i", "<C-c>", "<Esc>")

--save and format
vim.keymap.set("n", "<C-s>", function()
    vim.lsp.buf.format()
    vim.cmd("w")
end)

--replace macro
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- jump half screen but cursor stll remains center of screen.
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- resize window
vim.keymap.set("n", "(", ":horizontal resize -5<CR>")
vim.keymap.set("n", ")", ":horizontal resize +5<CR>")
vim.keymap.set("n", "-", ":vertical resize -5<CR>")
vim.keymap.set("n", "=", ":vertical resize +5<CR>")

-- TBE!
vim.keymap.set("n", "<leader>cc", "<cmd>Clipper<CR>")
