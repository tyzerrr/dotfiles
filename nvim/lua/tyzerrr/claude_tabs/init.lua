-- Claudeターミナルのタブ操作。新規タブ作成は本体のterminal.open経由で行い、
-- 本体が組み立てるenv(SSEポート等)をそのまま使う(provider.luaの規約を参照)。
local provider = require("tyzerrr.claude_tabs.provider")
local session = require("tyzerrr.claude_tabs.session")

local M = {}

M.provider = provider

local function open_tab(args)
	require("claudecode.terminal").open({}, args)
end

function M.new()
	open_tab(session.build_args({ session_id = session.uuid() }))
end

function M.fork()
	local source = provider.active_session_id()
	if not source then
		vim.notify("引き継ぎ元のClaudeセッションがありません", vim.log.levels.WARN)
		return
	end
	open_tab(session.build_args({ session_id = session.uuid(), fork_from = source }))
end

function M.next()
	provider.cycle(1)
end

function M.prev()
	provider.cycle(-1)
end

-- 実行中の作業も止まるので確認する。会話はtranscriptに残るため:ClaudeCode --resumeで戻れる。
function M.close()
	if not provider.get_active_bufnr() then
		return
	end
	local answer = vim.fn.confirm(
		"このClaudeタブを閉じますか？(Claudeは終了します。会話は <leader>ar で再開できます)",
		"&Yes\n&No",
		2
	)
	if answer == 1 then
		provider.close_tab()
	end
end

local function show_diff_origin(args)
	local data = args.data or {}
	local number = data.file_path and provider.tab_number_for_path(data.file_path)
	if not number then
		return
	end
	local label = string.format("Claude タブ%d からの変更", number)
	if data.diff_window and vim.api.nvim_win_is_valid(data.diff_window) then
		vim.wo[data.diff_window].winbar = label
	end
	vim.notify(label .. ": " .. vim.fn.fnamemodify(data.file_path, ":."), vim.log.levels.INFO)
end

function M.setup()
	require("tyzerrr.claude_tabs.send").install()
	vim.api.nvim_create_autocmd("User", {
		group = vim.api.nvim_create_augroup("ClaudeTabsDiffOrigin", { clear = true }),
		pattern = "ClaudeCodeDiffOpened",
		callback = show_diff_origin,
	})
end

return M
