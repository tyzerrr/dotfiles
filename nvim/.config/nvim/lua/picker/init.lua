---@class Opts: table<string, any>
---
local M = setmetatable({}, {
	__call = function(m, ...)
		return m.wrap(...)
	end,
})

--- metatable method to call from config-module
--- @param command string command name
--- @param opts Opts
--- @return function
M.wrap = function(command, opts)
	return function()
		M.pick(command, vim.deepcopy(opts))
	end
end

--- open target file that is confirmed by command name
--- @param command string command name
--- @param opts Opts
--- @return function
M.pick = function(command, opts)
	return function()
		require("telescope.builtin")[command](opts)
	end
end

--- open config files
M.config_files = function()
	local cwd = vim.fn.expand("~") .. "/.dotfiles/nvim/.config/nvim"
	return M.pick("find_files", { cwd = cwd })
end
return M
