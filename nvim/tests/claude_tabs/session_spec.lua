local session = require("tyzerrr.claude_tabs.session")

describe("session", function()
	it("uuidはClaude CLIが受け付けるv4形式で、呼ぶたびに異なる", function()
		local a = session.uuid()
		local b = session.uuid()

		assert.truthy(a:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-4%x%x%x%-[89ab]%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"))
		assert.are_not.equal(a, b)
	end)

	describe("build_args", function()
		it("新規セッションはsession-idだけを指定する", function()
			assert.are.equal("--session-id new-id", session.build_args({ session_id = "new-id" }))
		end)

		it("引き継ぎは元セッションをforkして新しいsession-idを割り当てる", function()
			assert.are.equal(
				"--resume src-id --fork-session --session-id new-id",
				session.build_args({ session_id = "new-id", fork_from = "src-id" })
			)
		end)
	end)

	describe("parse_args", function()
		it("コマンド文字列からsession-idとfork有無を取り出す", function()
			assert.are.same(
				{ session_id = "new-id", forked = true },
				session.parse_args("claude --resume src-id --fork-session --session-id new-id")
			)
		end)

		it("session-idがなければnil", function()
			assert.are.same({ session_id = nil, forked = false }, session.parse_args("claude --resume"))
		end)
	end)

	describe("read_status", function()
		it("hookが書いたTSVからsession_id・イベント名・対象パスを読む", function()
			local path = vim.fn.tempname()
			vim.fn.writefile({ "abc-123\tPreToolUse\t/repo/a.lua" }, path)

			assert.are.same(
				{ session_id = "abc-123", event = "PreToolUse", path = "/repo/a.lua" },
				session.read_status(path)
			)
		end)

		it("対象パスが空ならpathはnil", function()
			local path = vim.fn.tempname()
			vim.fn.writefile({ "abc-123\tStop\t" }, path)

			assert.are.same({ session_id = "abc-123", event = "Stop", path = nil }, session.read_status(path))
		end)

		it("ファイルがない、または空ならnil", function()
			local empty = vim.fn.tempname()
			vim.fn.writefile({}, empty)

			assert.is_nil(session.read_status(vim.fn.tempname()))
			assert.is_nil(session.read_status(empty))
		end)
	end)
end)
