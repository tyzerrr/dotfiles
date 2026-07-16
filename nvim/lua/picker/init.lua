---@class Opts: table<string, any>

--- Backend dispatchers. Command names are canonical (fzf-lua style);
--- each backend translates them to its own API where they differ.
local backends = {
	["fzf-lua"] = function(command, opts)
		require("fzf-lua")[command](opts)
	end,
	["telescope"] = function(command, opts)
		local aliases = { files = "find_files" }
		require("telescope.builtin")[aliases[command] or command](opts)
	end,
}

local M = setmetatable({}, {
	__call = function(m, ...)
		return m.wrap(...)
	end,
})

--- the single place to switch picker plugins
M.backend = "telescope"

--- metatable method to call from config-module
--- @param command string command name
--- @param opts Opts
--- @return function
M.wrap = function(command, opts)
	return function()
		M.pick(command, vim.deepcopy(opts))()
	end
end

--- open target file that is confirmed by command name
--- @param command string command name
--- @param opts Opts?
--- @return function
M.pick = function(command, opts)
	return function()
		backends[M.backend](command, opts)
	end
end

--- open config files
M.config_files = function()
	local cwd = vim.fn.expand("~") .. "/.dotfiles/nvim/.config/nvim"
	return M.pick("files", { cwd = cwd, hidden = true })
end

M.dotfiles = function()
	local cwd = vim.fn.expand("~") .. "/.dotfiles"
	return M.pick("files", { cwd = cwd, hidden = true })
end

M.personal_projects = function()
	local cwd = vim.fn.expand("~") .. "/personal"
	return M.pick("files", { cwd = cwd, hidden = true })
end
return M
