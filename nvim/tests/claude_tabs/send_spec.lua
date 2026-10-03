local send = require("tyzerrr.claude_tabs.send")
local provider = require("tyzerrr.claude_tabs.provider")
local server = require("claudecode.server.init")

-- claude本体(外部依存)の代わりに、端末から受け取った入力をそのままファイルに書くスクリプト。
local function fake_claude()
	local script = vim.fn.tempname()
	vim.fn.writefile({ "#!/bin/sh", "stty raw -echo", 'exec cat -u > "$FAKE_OUT"' }, script)
	vim.fn.setfperm(script, "rwx------")
	return script
end

local config = { split_side = "right", split_width_percentage = 0.3, auto_insert = false }

local function received(path)
	return table.concat(vim.fn.readfile(path, "b"), "\n")
end

-- 2つのタブを開き、それぞれの端末に届いた入力の書き込み先を返す
local function open_two_tabs()
	local cmd = fake_claude()
	provider.setup({ terminal_cmd = cmd })
	local inactive_out, active_out = vim.fn.tempname(), vim.fn.tempname()
	provider.open(cmd, { FAKE_OUT = inactive_out }, config, true)
	provider.open(cmd .. " --second", { FAKE_OUT = active_out }, config, true)
	vim.wait(3000, function()
		return vim.fn.filereadable(active_out) == 1 and vim.fn.filereadable(inactive_out) == 1
	end)
	return inactive_out, active_out
end

describe("send", function()
	describe("mention", function()
		it("cwdからの相対パスと行範囲を@メンションにする", function()
			assert.are.equal("@lua/foo.lua#L3-7 ", send.mention(vim.fn.getcwd() .. "/lua/foo.lua", 3, 7))
		end)

		it("1行だけなら範囲ではなく単一行にする", function()
			assert.are.equal("@lua/foo.lua#L5 ", send.mention("lua/foo.lua", 5, 5))
		end)

		it("行の指定がなければファイルだけ", function()
			assert.are.equal("@lua/ ", send.mention("lua/", nil, nil))
		end)
	end)

	describe("install", function()
		local original = server.broadcast

		before_each(function()
			send.install()
		end)

		after_each(function()
			provider._reset_for_test()
			server.broadcast = original
		end)

		it(
			"本体のat_mentionedを横取りし、アクティブなタブにだけ1始まりの行番号で書き込む",
			function()
				local inactive_out, active_out = open_two_tabs()

				local ok = server.broadcast("at_mentioned", { filePath = "lua/a.lua", lineStart = 2, lineEnd = 3 })

				assert.is_true(ok)
				vim.wait(3000, function()
					return #received(active_out) > 0
				end)
				assert.are.equal("\27[200~@lua/a.lua#L3-4 \27[201~", received(active_out))
				assert.are.equal("", received(inactive_out))
			end
		)

		it("at_mentioned以外のメッセージは本体の処理にそのまま渡す", function()
			local inactive_out, active_out = open_two_tabs()

			-- サーバー未起動なので本体のbroadcastはfalseを返す
			assert.is_false(server.broadcast("selection_changed", {}))

			vim.wait(300)
			assert.are.equal("", received(active_out))
			assert.are.equal("", received(inactive_out))
		end)

		it("タブがなければ本体の処理に任せる", function()
			assert.is_false(server.broadcast("at_mentioned", { filePath = "lua/a.lua" }))
		end)

		it("2回installしても二重に書き込まない", function()
			local _, active_out = open_two_tabs()
			send.install()

			server.broadcast("at_mentioned", { filePath = "lua/a.lua" })

			vim.wait(3000, function()
				return #received(active_out) > 0
			end)
			vim.wait(300)
			assert.are.equal("\27[200~@lua/a.lua \27[201~", received(active_out))
		end)
	end)
end)
