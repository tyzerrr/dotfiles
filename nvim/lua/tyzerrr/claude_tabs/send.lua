-- ファイルや選択範囲の送信をアクティブなタブのClaudeにだけ届ける。
-- 本体の:ClaudeCodeSend/:ClaudeCodeAdd/TreeAddは接続中の全クライアントへat_mentionedをbroadcastするため、
-- タブが複数あると全セッションに届いてしまう。本体の内部ではなくClaude CLIとのプロトコル
-- (at_mentioned)の境界で横取りし、代わりにアクティブなタブの端末へ@メンションを書き込む。
local provider = require("tyzerrr.claude_tabs.provider")

local M = {}

function M.mention(file, start_line, end_line)
	local range = ""
	if start_line then
		range = start_line == end_line and ("#L" .. start_line) or string.format("#L%d-%d", start_line, end_line)
	end
	local path = vim.fn.fnamemodify(file, ":.")
	-- ディレクトリを示す末尾の/はfnamemodifyで落ちるが、Claudeの解釈に必要なので残す
	if vim.endswith(file, "/") and not vim.endswith(path, "/") then
		path = path .. "/"
	end
	return "@" .. path .. range .. " "
end

function M.to_active(text)
	local buf = provider.get_active_bufnr()
	if not buf then
		return false
	end
	-- 1文字ずつ届くと@でClaudeのファイル補完ポップアップが開くため、貼り付けとして一括で渡す
	vim.fn.chansend(vim.bo[buf].channel, "\27[200~" .. text .. "\27[201~")
	return true
end

local wrapper = nil

function M.install()
	local server = require("claudecode.server.init")
	if server.broadcast == wrapper then
		return
	end
	local original = server.broadcast
	wrapper = function(method, params)
		if method == "at_mentioned" and provider.get_active_bufnr() then
			-- プロトコルの行番号は0始まり
			local first = params.lineStart and params.lineStart + 1
			local last = params.lineEnd and params.lineEnd + 1 or first
			return M.to_active(M.mention(params.filePath, first, last))
		end
		return original(method, params)
	end
	server.broadcast = wrapper
end

return M
