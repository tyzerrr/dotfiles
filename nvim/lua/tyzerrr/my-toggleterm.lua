local M = {}

M.state = {
	floating = {
		win = -1,
		buf = -1,
	},
}

M.toggle_terminal = function()
	if not vim.api.nvim_win_is_valid(M.state.floating.win) then
		M.state.floating = require("utils.lib").create_floating_window({ buf = M.state.floating.buf })
		if vim.bo[M.state.floating.buf].buftype ~= "terminal" then
			vim.cmd("terminal")
		end
		vim.cmd("startinsert")
	else
		vim.api.nvim_win_hide(M.state.floating.win)
	end
end

vim.api.nvim_create_user_command("PrimeFloating", M.toggle_terminal, {})
vim.keymap.set({ "n", "t" }, "<C-t>", M.toggle_terminal, { desc = "Toggle Floating Terminal" })

return M
