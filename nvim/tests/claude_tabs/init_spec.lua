local claude_tabs = require("tyzerrr.claude_tabs")
local provider = require("tyzerrr.claude_tabs.provider")

-- claude本体(外部依存)の代わりに、受け取った引数とsession fileのパスを書いて待機するスクリプト。
-- 書き込み先はタブごとに分けたいので、起動順の連番ファイルにする。
local function fake_claude(out_dir)
	local script = vim.fn.tempname()
	vim.fn.writefile({
		"#!/bin/sh",
		string.format('n=$(ls "%s" | wc -l | tr -d " ")', out_dir),
		string.format('printf "%%s\\n" "$*" "$NVIM_CLAUDE_SESSION_FILE" > "%s/$n"', out_dir),
		"exec sleep 600",
	}, script)
	vim.fn.setfperm(script, "rwx------")
	return script
end

local function wait_launch(out_dir, n)
	local path = out_dir .. "/" .. n
	vim.wait(3000, function()
		return vim.fn.filereadable(path) == 1 and #vim.fn.readfile(path) >= 2
	end)
	return vim.fn.readfile(path)
end

describe("claude_tabs", function()
	local out_dir

	before_each(function()
		provider._reset_for_test()
		vim.cmd("silent! only")
		out_dir = vim.fn.tempname()
		vim.fn.mkdir(out_dir, "p")
		-- 本体のterminalモジュール経由で呼ぶことで、envの組み立てを含めた実際の経路を通す
		require("claudecode.terminal").setup({ provider = provider, auto_insert = false }, fake_claude(out_dir))
	end)

	after_each(function()
		provider._reset_for_test()
	end)

	it(
		"本体がdiffを開いたら、編集しようとしたタブの番号をdiffウィンドウに表示する",
		function()
			claude_tabs.setup()
			claude_tabs.new()
			wait_launch(out_dir, 0)
			claude_tabs.new()
			local second = wait_launch(out_dir, 1)
			vim.fn.writefile({ "id-2\tPreToolUse\t/repo/a.lua" }, second[2])
			vim.wait(3000, function()
				return provider.tab_number_for_path("/repo/a.lua") == 2
			end)
			vim.cmd("wincmd t")
			local diff_win = vim.api.nvim_get_current_win()

			vim.api.nvim_exec_autocmds("User", {
				pattern = "ClaudeCodeDiffOpened",
				data = { file_path = "/repo/a.lua", diff_window = diff_win },
			})

			assert.are.equal("Claude タブ2 からの変更", vim.wo[diff_win].winbar)
		end
	)

	it("newは既存タブとは別に新しいsession-idのタブを作る", function()
		claude_tabs.new()
		local first = wait_launch(out_dir, 0)

		claude_tabs.new()
		local second = wait_launch(out_dir, 1)

		assert.truthy(second[1]:match("^%-%-session%-id %x+"))
		assert.are_not.equal(first[1], second[1])
	end)

	it("forkはアクティブなタブの最新session_idを引き継いで新しいタブを作る", function()
		claude_tabs.new()
		local first = wait_launch(out_dir, 0)
		vim.fn.writefile({ "latest-id" }, first[2])

		claude_tabs.fork()
		local forked = wait_launch(out_dir, 1)

		assert.truthy(forked[1]:match("^%-%-resume latest%-id %-%-fork%-session %-%-session%-id %x+"))
		assert.truthy(vim.wo[vim.api.nvim_get_current_win()].winbar:find("2⑂", 1, true))
	end)

	it("タブがなければforkは何も起動しない", function()
		claude_tabs.fork()

		assert.is_nil(provider.get_active_bufnr())
	end)

	it(
		":ClaudeCode --resume(simple_toggle)は既存タブを残したまま新しいタブでピッカーを開く",
		function()
			claude_tabs.new()
			wait_launch(out_dir, 0)

			require("claudecode.terminal").simple_toggle({}, "--resume")

			assert.are.equal("--resume", wait_launch(out_dir, 1)[1])
			assert.are.equal(
				"%#TabLine# 1 %#TabLineSel# 2 %#TabLineFill#",
				vim.wo[vim.api.nvim_get_current_win()].winbar
			)
		end
	)
end)
