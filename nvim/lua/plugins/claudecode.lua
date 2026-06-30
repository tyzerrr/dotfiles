-- Claudeターミナルのウィンドウを探す（エディタ側にフォーカスがあっても操作できるように）。
local function find_claude_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_get_name(buf):match("claude") then
			return win
		end
	end
end

-- 選択範囲をClaudeに送信したあと、ターミナルにフォーカスしてInsertモードに入る。
-- 送信直後に続けて入力したいときの操作を一手で済ませる。
local function send_and_insert()
	vim.cmd("ClaudeCodeSend")
	-- ClaudeCodeSendは非同期にウィンドウを開く場合があるため、フォーカスは次のtickで行う。
	vim.schedule(function()
		local win = find_claude_win()
		if win then
			vim.api.nvim_set_current_win(win)
			vim.cmd("startinsert")
		end
	end)
end

-- 既定サイズ⇔フルスクリーンをトグルする。元の幅をウィンドウ変数に退避して復元する。
local function toggle_claude_size()
	local win = find_claude_win()
	if not win then
		return
	end
	local ok, saved = pcall(vim.api.nvim_win_get_var, win, "claude_saved_width")
	if ok and saved then
		vim.api.nvim_win_set_width(win, saved)
		vim.api.nvim_win_del_var(win, "claude_saved_width")
	else
		vim.api.nvim_win_set_var(win, "claude_saved_width", vim.api.nvim_win_get_width(win))
		vim.api.nvim_win_set_width(win, vim.o.columns)
	end
end

return {
	"coder/claudecode.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/snacks.nvim",
	},
	config = function()
		require("claudecode").setup({
			terminal = {
				-- normalモードでスクロールしてから戻ってもinsertに飛ばされず、
				-- スクロール位置を保持する。Ink TUIの再描画ズレを抑える（#232）。
				-- 入力したいときは `i` を押す。
				auto_insert = false,
			},
		})

		-- エディタを閉じたとき、残るのがClaudeターミナルだけになるなら一緒に閉じる。
		-- ターミナルだけが取り残されてnvimが終了できない状態を避ける。
		vim.api.nvim_create_autocmd("QuitPre", {
			group = vim.api.nvim_create_augroup("ClaudeCloseWithEditor", { clear = true }),
			callback = function()
				-- これから閉じるウィンドウも含めた、フロート以外の非ターミナルウィンドウ数。
				-- 1以下なら今閉じるのが最後のエディタなので、ターミナルも畳む。
				local editor_wins = 0
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					local floating = vim.api.nvim_win_get_config(win).relative ~= ""
					if not floating and vim.bo[buf].buftype ~= "terminal" then
						editor_wins = editor_wins + 1
					end
				end
				if editor_wins <= 1 then
					local win = find_claude_win()
					if win then
						pcall(vim.api.nvim_win_close, win, true)
					end
				end
			end,
		})
	end,
	keys = {
		{ "<C-l>", send_and_insert, desc = "選択範囲を送信してInsert", mode = "v" },
		{ "<leader>af", toggle_claude_size, desc = "Claudeターミナルのサイズ切替" },
		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude Codeを切り替え" },
		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "セッションを再開" },
	},
}
