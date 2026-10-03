local provider = require("tyzerrr.claude_tabs.provider")

-- claude本体(外部依存)の代わりに、受け取った引数と環境変数をファイルに書いて待機するスクリプトを使う。
local function fake_claude()
	local script = vim.fn.tempname()
	vim.fn.writefile({
		"#!/bin/sh",
		'printf "%s\\n" "$*" "$NVIM_CLAUDE_SESSION_FILE" "$EXTRA_ENV" > "$FAKE_OUT"',
		'[ -n "$FAKE_EXIT" ] && exit 0',
		"exec sleep 600",
	}, script)
	vim.fn.setfperm(script, "rwx------")
	return script
end

local function wait_lines(path)
	vim.wait(3000, function()
		return vim.fn.filereadable(path) == 1 and #vim.fn.readfile(path) >= 3
	end)
	return vim.fn.readfile(path)
end

local config = { split_side = "right", split_width_percentage = 0.3, auto_insert = false }

describe("provider", function()
	local cmd, out

	before_each(function()
		provider._reset_for_test()
		vim.cmd("silent! only")
		cmd = fake_claude()
		out = vim.fn.tempname()
		provider.setup({ terminal_cmd = cmd })
	end)

	after_each(function()
		provider._reset_for_test()
	end)

	describe("open", function()
		it("タブがなければsession-idを割り当てて右側にClaudeを起動する", function()
			local editor = vim.api.nvim_get_current_win()

			provider.open(cmd, { FAKE_OUT = out, EXTRA_ENV = "from-core" }, config, true)
			local lines = wait_lines(out)

			assert.truthy(lines[1]:match("^%-%-session%-id %x+%-"))
			assert.truthy(lines[2]:match("claude_tabs/"))
			assert.are.equal("from-core", lines[3])
			local win = vim.api.nvim_get_current_win()
			assert.are_not.equal(editor, win)
			assert.are.equal(provider.get_active_bufnr(), vim.api.nvim_win_get_buf(win))
			assert.are.equal(vim.o.columns, vim.api.nvim_win_get_position(win)[2] + vim.api.nvim_win_get_width(win))
		end)

		it("引数なしで再度openしても新しいタブは作らない", function()
			provider.open(cmd, { FAKE_OUT = out }, config, true)
			local first = provider.get_active_bufnr()

			provider.open(cmd, { FAKE_OUT = out }, config, true)

			assert.are.equal(first, provider.get_active_bufnr())
			assert.are.equal(1, #vim.api.nvim_list_wins() - 1)
		end)

		it("focus=falseなら元のウィンドウに留まる", function()
			local editor = vim.api.nvim_get_current_win()

			provider.open(cmd, { FAKE_OUT = out }, config, false)

			assert.are.equal(editor, vim.api.nvim_get_current_win())
			assert.are.equal(2, #vim.api.nvim_list_wins())
		end)

		it(
			"引数付きでopenすると同じウィンドウに新しいタブを作り、引数をそのまま渡す",
			function()
				provider.open(cmd, { FAKE_OUT = vim.fn.tempname() }, config, true)
				local first = provider.get_active_bufnr()

				provider.open(cmd .. " --resume", { FAKE_OUT = out }, config, true)
				local lines = wait_lines(out)

				assert.are.equal("--resume", lines[1])
				assert.are_not.equal(first, provider.get_active_bufnr())
				assert.are.equal(2, #vim.api.nvim_list_wins())
				assert.are.equal(
					"%#TabLine# 1 %#TabLineSel# 2 %#TabLineFill#",
					vim.wo[vim.api.nvim_get_current_win()].winbar
				)
			end
		)
	end)

	describe("toggle", function()
		it(
			"simple_toggleでウィンドウを隠しても、プロセスは生きたまま再表示できる",
			function()
				provider.open(cmd, { FAKE_OUT = out }, config, true)
				local buf = provider.get_active_bufnr()

				provider.simple_toggle(cmd, {}, config)
				assert.are.equal(1, #vim.api.nvim_list_wins())

				provider.simple_toggle(cmd, {}, config)
				assert.are.equal(2, #vim.api.nvim_list_wins())
				assert.are.equal(buf, vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win()))
				assert.are.equal(-1, vim.fn.jobwait({ vim.bo[buf].channel }, 0)[1])
			end
		)

		it(
			"focus_toggleは別ウィンドウにいればフォーカスし、ターミナル内にいれば隠す",
			function()
				local editor = vim.api.nvim_get_current_win()
				provider.open(cmd, { FAKE_OUT = out }, config, false)

				provider.focus_toggle(cmd, {}, config)
				assert.are_not.equal(editor, vim.api.nvim_get_current_win())

				provider.focus_toggle(cmd, {}, config)
				assert.are.equal(1, #vim.api.nvim_list_wins())
			end
		)
	end)

	describe("タブ操作", function()
		it("cycleで表示中のバッファが切り替わる", function()
			provider.open(cmd, { FAKE_OUT = vim.fn.tempname() }, config, true)
			local first = provider.get_active_bufnr()
			provider.open(cmd .. " --x", { FAKE_OUT = vim.fn.tempname() }, config, true)

			provider.cycle(1)

			assert.are.equal(first, provider.get_active_bufnr())
			assert.are.equal(first, vim.api.nvim_win_get_buf(vim.api.nvim_get_current_win()))
		end)

		it("close_tabでアクティブなタブのプロセスを止め、残りのタブを表示する", function()
			provider.open(cmd, { FAKE_OUT = vim.fn.tempname() }, config, true)
			local first = provider.get_active_bufnr()
			provider.open(cmd .. " --x", { FAKE_OUT = vim.fn.tempname() }, config, true)
			local second = provider.get_active_bufnr()

			provider.close_tab()

			vim.wait(2000, function()
				return not vim.api.nvim_buf_is_valid(second)
			end)
			assert.is_false(vim.api.nvim_buf_is_valid(second))
			assert.are.equal(first, provider.get_active_bufnr())
		end)

		it("Claudeが終了したタブは消え、最後の1つならウィンドウも閉じる", function()
			provider.open(cmd, { FAKE_OUT = out, FAKE_EXIT = "1" }, config, true)

			vim.wait(3000, function()
				return provider.get_active_bufnr() == nil
			end)

			assert.is_nil(provider.get_active_bufnr())
			assert.are.equal(1, #vim.api.nvim_list_wins())
		end)
	end)

	describe("active_session_id", function()
		it("hookが書いたIDがあればそれを優先する", function()
			provider.open(cmd, { FAKE_OUT = out }, config, true)
			local session_file = wait_lines(out)[2]

			vim.fn.writefile({ "id-after-clear\tSessionStart\t" }, session_file)

			assert.are.equal("id-after-clear", provider.active_session_id())
		end)

		it("hookのファイルがなければ起動時に割り当てたIDを返す", function()
			provider.open(cmd, { FAKE_OUT = out }, config, true)
			local assigned = wait_lines(out)[1]:match("%-%-session%-id (%S+)")

			assert.are.equal(assigned, provider.active_session_id())
		end)
	end)

	describe("hookのイベント", function()
		local function open_two_tabs()
			local first_out = vim.fn.tempname()
			provider.open(cmd, { FAKE_OUT = first_out }, config, true)
			provider.open(cmd .. " --x", { FAKE_OUT = out }, config, true)
			return wait_lines(first_out)[2], wait_lines(out)[2]
		end

		local function winbar()
			return vim.wo[vim.fn.bufwinid(provider.get_active_bufnr())].winbar
		end

		it("裏のタブが許可待ちになったらwinbarに!を出す", function()
			local first_file = open_two_tabs()

			vim.fn.writefile({ "id-1\tPermissionRequest\t" }, first_file)

			assert.is_true(vim.wait(3000, function()
				return winbar():find("1%#DiagnosticError#!", 1, true) ~= nil
			end))
		end)

		it(
			"直近に編集しようとしたファイルのパスから、そのタブの番号が分かる",
			function()
				local _, second_file = open_two_tabs()

				vim.fn.writefile({ "id-2\tPreToolUse\t/repo/a.lua" }, second_file)

				assert.is_true(vim.wait(3000, function()
					return provider.tab_number_for_path("/repo/a.lua") == 2
				end))
				assert.is_nil(provider.tab_number_for_path("/repo/other.lua"))
			end
		)
	end)

	it("Claudeが設定した端末タイトルをタブ名に表示する", function()
		provider.open(cmd, { FAKE_OUT = out }, config, true)
		local buf = provider.get_active_bufnr()

		vim.b[buf].term_title = "✳ Fix login bug"

		assert.is_true(vim.wait(3000, function()
			return vim.wo[vim.fn.bufwinid(buf)].winbar:find("Fix login bug", 1, true) ~= nil
		end))
	end)

	describe("セッションファイルの掃除", function()
		it("タブが終了したらそのタブのファイルを消す", function()
			provider.open(cmd, { FAKE_OUT = out, FAKE_EXIT = "1" }, config, true)
			local session_file = wait_lines(out)[2]
			vim.fn.writefile({ "id\tStop\t" }, session_file)

			vim.wait(3000, function()
				return provider.get_active_bufnr() == nil
			end)

			assert.are.equal(0, vim.fn.filereadable(session_file))
		end)

		it("setupで、終了済みのnvimが残したファイルだけを消す", function()
			local dead = vim.fn.jobstart({ "true" })
			local dead_pid = vim.fn.jobpid(dead)
			vim.fn.jobwait({ dead }, 2000)
			local dir = vim.fn.stdpath("state") .. "/claude_tabs"
			vim.fn.mkdir(dir, "p")
			local stale = string.format("%s/%d-stale", dir, dead_pid)
			local own = string.format("%s/%d-own", dir, vim.fn.getpid())
			vim.fn.writefile({ "x" }, stale)
			vim.fn.writefile({ "x" }, own)

			provider.setup({ terminal_cmd = cmd })

			assert.are.equal(0, vim.fn.filereadable(stale))
			assert.are.equal(1, vim.fn.filereadable(own))
		end)
	end)

	it(
		"Claudeのウィンドウで別のバッファを開いていたら、そのウィンドウは使わず新しく分割する",
		function()
			provider.open(cmd, { FAKE_OUT = out }, config, true)
			local repurposed = vim.api.nvim_get_current_win()
			vim.cmd("enew")
			local user_buf = vim.api.nvim_get_current_buf()

			provider.open(cmd, {}, config, true)

			assert.are.equal(user_buf, vim.api.nvim_win_get_buf(repurposed))
			assert.are_not.equal(repurposed, vim.api.nvim_get_current_win())
			assert.are.equal(provider.get_active_bufnr(), vim.api.nvim_get_current_buf())
		end
	)
end)
