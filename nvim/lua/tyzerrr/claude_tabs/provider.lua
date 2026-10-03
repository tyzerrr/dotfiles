-- claudecode.nvimのcustom terminal provider。右側の1ウィンドウに表示するターミナルバッファを
-- 差し替えることで、複数のClaudeセッションをタブとして扱う。
-- envの組み立て(SSEポート/no_proxy等)は本体に任せたいので、本体経由で引数付きopenされたら
-- 「新しいタブを作る」、引数なしなら「既存タブを表示する」という規約で新規タブ作成を受け取る。
local tabs = require("tyzerrr.claude_tabs.tabs")
local session = require("tyzerrr.claude_tabs.session")

local M = {}

local state = tabs.new()
local win = nil
local base_cmd = "claude"
local last_config = {}
local session_dir = vim.fn.stdpath("state") .. "/claude_tabs"

local function win_valid()
	return win ~= nil and vim.api.nvim_win_is_valid(win)
end

local function is_visible()
	local tab = tabs.active(state)
	return tab ~= nil and win_valid() and vim.api.nvim_win_get_buf(win) == tab.buf
end

local function has_extra_args(cmd_string)
	return vim.trim(cmd_string) ~= base_cmd
end

local function enter(config, focus, original)
	if focus then
		vim.api.nvim_set_current_win(win)
		if config.auto_insert ~= false then
			vim.cmd("startinsert")
		end
	elseif original and vim.api.nvim_win_is_valid(original) then
		vim.api.nvim_set_current_win(original)
	end
end

local function render()
	if win_valid() then
		local label = tabs.label(state)
		if vim.wo[win].winbar ~= label then
			vim.wo[win].winbar = label
		end
	end
end

local function index_of(tab)
	for i, item in ipairs(state.items) do
		if item == tab then
			return i
		end
	end
end

-- hookがセッションファイルを書き換えたら、そのタブの状態(許可待ち/完了)と直近の編集対象を更新する。
local function on_session_file_changed(filename)
	local tab
	for _, item in ipairs(state.items) do
		if item.session_file == session_dir .. "/" .. filename then
			tab = item
		end
	end
	-- jqの書き込み途中(空ファイル)で読むことがあるので、内容が揃っていなければ次の通知を待つ
	local status = tab and session.read_status(tab.session_file)
	if not status then
		return
	end
	if status.event == "PreToolUse" and status.path then
		tab.edit_path = vim.fs.normalize(status.path)
	end
	local was = tab.status
	tabs.apply_event(state, tab, status.event)
	if tab.status == "attention" and was ~= "attention" and tab ~= tabs.active(state) then
		vim.notify(string.format("Claude タブ%d が入力を待っています", index_of(tab)), vim.log.levels.WARN)
	end
	render()
end

local watcher = nil
local function watch_session_dir()
	if watcher then
		return
	end
	vim.fn.mkdir(session_dir, "p")
	watcher = vim.uv.new_fs_event()
	watcher:start(
		session_dir,
		{},
		vim.schedule_wrap(function(err, filename)
			if not err and filename then
				on_session_file_changed(filename)
			end
		end)
	)
end

-- Claudeは会話の要約を端末タイトルに設定するが、変更を知らせるイベントがないので定期的に拾う。
local title_timer = nil
local function start_title_refresh()
	if title_timer then
		return
	end
	title_timer = vim.uv.new_timer()
	title_timer:start(
		1000,
		1000,
		vim.schedule_wrap(function()
			for _, tab in ipairs(state.items) do
				if vim.api.nvim_buf_is_valid(tab.buf) then
					tab.title = tabs.clean_title(vim.b[tab.buf].term_title)
				end
			end
			render()
		end)
	)
end

local function remove_stale_session_files()
	for name, kind in vim.fs.dir(session_dir) do
		local pid = tonumber(name:match("^(%d+)%-"))
		if kind == "file" and pid and pid ~= vim.fn.getpid() and vim.uv.kill(pid, 0) ~= 0 then
			os.remove(session_dir .. "/" .. name)
		end
	end
end

-- ウィンドウを(なければ作って)アクティブなタブのバッファで表示する。
local function show(config, focus)
	local original = vim.api.nvim_get_current_win()
	-- ユーザーがClaudeのウィンドウで別のバッファを開いたら、そのウィンドウはユーザーのものとして手放す
	if win_valid() and not tabs.find_by_buf(state, vim.api.nvim_win_get_buf(win)) then
		win = nil
	end
	if not win_valid() then
		local placement = config.split_side == "left" and "topleft " or "botright "
		local width = math.floor(vim.o.columns * (config.split_width_percentage or 0.3))
		vim.cmd(placement .. width .. "vsplit")
		win = vim.api.nvim_get_current_win()
		vim.wo[win].number = false
		vim.wo[win].relativenumber = false
		vim.wo[win].signcolumn = "no"
	end
	vim.api.nvim_win_set_buf(win, tabs.active(state).buf)
	render()
	enter(config, focus, original)
end

local function hide()
	-- 最後の1ウィンドウは閉じられない(E444)ので失敗は無視する
	if win_valid() and pcall(vim.api.nvim_win_close, win, false) then
		win = nil
	end
end

local function on_exit(tab)
	vim.schedule(function()
		os.remove(tab.session_file)
		tabs.remove(state, tab)
		if vim.api.nvim_buf_is_valid(tab.buf) then
			-- 表示中のバッファを消すとウィンドウごと閉じるので、先に次のタブへ差し替える
			if tabs.active(state) and win_valid() and vim.api.nvim_win_get_buf(win) == tab.buf then
				vim.api.nvim_win_set_buf(win, tabs.active(state).buf)
			end
			vim.api.nvim_buf_delete(tab.buf, { force = true })
		end
		if tabs.active(state) then
			render()
		else
			hide()
		end
	end)
end

local function create_tab(cmd_string, env_table, config, focus)
	local original = vim.api.nvim_get_current_win()
	-- 引数なしの新規起動にはIDを割り当て、後から--resumeで引き継げるようにする。
	-- --resume等の引数付き起動ではIDを指定できないので、hookから届くIDだけで追跡する。
	if not has_extra_args(cmd_string) then
		cmd_string = cmd_string .. " " .. session.build_args({ session_id = session.uuid() })
	end
	watch_session_dir()
	start_title_refresh()
	local session_file = string.format("%s/%d-%s", session_dir, vim.fn.getpid(), session.uuid())
	local parsed = session.parse_args(cmd_string)

	local buf = vim.api.nvim_create_buf(false, true)
	local tab = tabs.add(state, {
		buf = buf,
		session_id = parsed.session_id,
		forked = parsed.forked,
		session_file = session_file,
	})
	show(config, true)
	vim.fn.jobstart(require("claudecode.utils").parse_command(cmd_string), {
		term = true,
		cwd = config.cwd,
		env = vim.tbl_extend("force", env_table, { NVIM_CLAUDE_SESSION_FILE = session_file }),
		on_exit = function()
			on_exit(tab)
		end,
	})
	vim.bo[buf].bufhidden = "hide"
	enter(config, focus, original)
end

function M.setup(config)
	base_cmd = (config and config.terminal_cmd) or "claude"
	vim.fn.mkdir(session_dir, "p")
	remove_stale_session_files()
end

function M.open(cmd_string, env_table, config, focus)
	last_config = config
	if focus == nil then
		focus = true
	end
	if has_extra_args(cmd_string) or not tabs.active(state) then
		create_tab(cmd_string, env_table, config, focus)
	else
		show(config, focus)
	end
end

function M.close()
	hide()
end

function M.simple_toggle(cmd_string, env_table, config)
	if is_visible() and not has_extra_args(cmd_string) then
		hide()
	else
		M.open(cmd_string, env_table, config, true)
	end
end

function M.focus_toggle(cmd_string, env_table, config)
	if is_visible() and not has_extra_args(cmd_string) and vim.api.nvim_get_current_win() == win then
		hide()
	else
		M.open(cmd_string, env_table, config, true)
	end
end

function M.get_active_bufnr()
	local tab = tabs.active(state)
	return tab and tab.buf
end

function M.is_available()
	return true
end

function M.cycle(delta)
	if #state.items < 2 then
		return
	end
	tabs.cycle(state, delta)
	show(last_config, win_valid() and vim.api.nvim_get_current_win() == win)
end

function M.close_tab()
	local tab = tabs.active(state)
	if tab then
		vim.fn.jobstop(vim.bo[tab.buf].channel)
	end
end

function M.active_session_id()
	local tab = tabs.active(state)
	if not tab then
		return nil
	end
	local status = session.read_status(tab.session_file)
	return status and status.session_id or tab.session_id
end

-- diffを出したタブを特定するため、PreToolUseで記録した直近の編集対象と照合する
function M.tab_number_for_path(path)
	path = vim.fs.normalize(path)
	for i, item in ipairs(state.items) do
		if item.edit_path == path then
			return i
		end
	end
end

function M._reset_for_test()
	local chans = {}
	for _, tab in ipairs(state.items) do
		table.insert(chans, vim.bo[tab.buf].channel)
		pcall(vim.fn.jobstop, vim.bo[tab.buf].channel)
	end
	-- 終了しきる前にテストランナーがos.exitすると、ptyの後始末待ちでnvimが終了できなくなる
	vim.fn.jobwait(chans, 2000)
	for _, tab in ipairs(state.items) do
		pcall(vim.api.nvim_buf_delete, tab.buf, { force = true })
	end
	state = tabs.new()
	hide()
	win = nil
end

return M
