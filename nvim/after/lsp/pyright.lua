local function is_python_project()
	local cwd = vim.fn.getcwd()

	local is_python_cfg_exists = vim.fn.filereadable(cwd .. "/pyproject.toml")
		or vim.fn.filereadable(cwd .. "/setup.py")
		or vim.fn.filereadable(cwd .. "/requirements.txt")
		or vim.fn.filereadable(cwd .. "/setup.cfg")
		or vim.fn.filereadable(cwd .. "/Pipfile")
		or vim.fn.filereadable(cwd .. "/poetry.lock")
		or vim.fn.filereadable(cwd .. "/Pipfile.lock")
		or vim.fn.filereadable(cwd .. "/poetry.lock")
		or vim.fn.filereadable(cwd .. "/requirements.in")

	local is_venv_dir_exists = vim.loop.fs_stat(cwd .. "/venv") ~= nil or vim.loop.fs_stat(cwd .. "/.venv") ~= nil

	return is_python_cfg_exists ~= 0 or is_venv_dir_exists
end

local function is_directory(path)
	local stat = vim.loop.fs_stat(path)
	return stat and stat.type == "directory"
end

local function get_python_path()
	local cwd = vim.fn.getcwd()
	local pyproject_toml = cwd .. "/pyproject.toml"
	local virtualenv = cwd .. "/venv"
	local uv_rye_env = cwd .. "/.venv"
	-- using poetry or uv or rye
	if vim.fn.filereadable(pyproject_toml) == 1 then
		local poetry_venv = vim.fn.trim(vim.fn.system("poetry env info --path"))
		-- using poetry
		-- vim.v means vim.variable, and vim.v.shell_error means resulf of the last shell comand. (See: :h v:shell_error)
		if vim.v.shell_error == 0 and poetry_venv ~= "" then
			vim.notify("[From Pyright] Using poetry settings", vim.log.levels.INFO)
			return poetry_venv .. "/bin/python"
			-- using rye or uv, but no other differences using .venv directory.
		elseif is_directory(uv_rye_env) then
			vim.notify("[From Pyright] Using rye or uv settings", vim.log.levels.INFO)
			return uv_rye_env .. "/bin/python3"
		end
	end
	-- using virtualenv
	if is_directory(virtualenv) then
		vim.notify("[From Pyright] Using venv settings", vim.log.levels.INFO)
		return virtualenv .. "/bin/python3"
	else
		if is_python_project() then
			vim.notify("Virtual environment not found. Using default Python.", vim.log.levels.INFO)
		end
	end
	return vim.fn.exepath("python3")
end

return {
	settings = {
		python = {
			pythonPath = get_python_path(),
		},
	},
}
