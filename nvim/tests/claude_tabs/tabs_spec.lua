local tabs = require("tyzerrr.claude_tabs.tabs")

describe("tabs", function()
	it("追加したタブがアクティブになる", function()
		local state = tabs.new()

		tabs.add(state, { buf = 10 })
		local second = tabs.add(state, { buf = 20 })

		assert.are.equal(2, #state.items)
		assert.are.equal(second, tabs.active(state))
	end)

	it("空のときactiveはnilを返す", function()
		assert.is_nil(tabs.active(tabs.new()))
	end)

	describe("remove", function()
		it("アクティブなタブを消すと同じ位置(右隣)のタブがアクティブになる", function()
			local state = tabs.new()
			local first = tabs.add(state, { buf = 10 })
			tabs.add(state, { buf = 20 })
			local third = tabs.add(state, { buf = 30 })
			tabs.activate(state, first)

			tabs.remove(state, first)

			assert.are.same(
				{ 20, 30 },
				vim.tbl_map(function(t)
					return t.buf
				end, state.items)
			)
			assert.are.equal(20, tabs.active(state).buf)
			assert.are_not.equal(third, tabs.active(state))
		end)

		it("末尾のアクティブなタブを消すと左隣がアクティブになる", function()
			local state = tabs.new()
			tabs.add(state, { buf = 10 })
			local last = tabs.add(state, { buf = 20 })

			tabs.remove(state, last)

			assert.are.equal(10, tabs.active(state).buf)
		end)

		it("非アクティブなタブを消してもアクティブは変わらない", function()
			local state = tabs.new()
			local first = tabs.add(state, { buf = 10 })
			local second = tabs.add(state, { buf = 20 })

			tabs.remove(state, first)

			assert.are.equal(second, tabs.active(state))
		end)

		it("最後の1つを消すとactiveはnilになる", function()
			local state = tabs.new()
			local only = tabs.add(state, { buf = 10 })

			tabs.remove(state, only)

			assert.is_nil(tabs.active(state))
		end)
	end)

	describe("cycle", function()
		it("次へ進み、末尾からは先頭に戻る", function()
			local state = tabs.new()
			tabs.add(state, { buf = 10 })
			tabs.add(state, { buf = 20 })

			tabs.cycle(state, 1)

			assert.are.equal(10, tabs.active(state).buf)
		end)

		it("前へ戻り、先頭からは末尾に回る", function()
			local state = tabs.new()
			tabs.add(state, { buf = 10 })
			tabs.add(state, { buf = 20 })
			tabs.cycle(state, 1)

			tabs.cycle(state, -1)

			assert.are.equal(20, tabs.active(state).buf)
		end)
	end)

	it("バッファ番号からタブを引ける", function()
		local state = tabs.new()
		tabs.add(state, { buf = 10 })
		local second = tabs.add(state, { buf = 20 })

		assert.are.equal(second, tabs.find_by_buf(state, 20))
		assert.is_nil(tabs.find_by_buf(state, 99))
	end)

	describe("label", function()
		it("位置番号を並べ、アクティブなタブだけTabLineSelで強調する", function()
			local state = tabs.new()
			tabs.add(state, { buf = 10 })
			tabs.add(state, { buf = 20 })

			assert.are.equal("%#TabLine# 1 %#TabLineSel# 2 %#TabLineFill#", tabs.label(state))
		end)

		it("引き継ぎで作ったタブには⑂を付ける", function()
			local state = tabs.new()
			tabs.add(state, { buf = 10 })
			tabs.add(state, { buf = 20, forked = true })

			assert.are.equal("%#TabLine# 1 %#TabLineSel# 2⑂ %#TabLineFill#", tabs.label(state))
		end)

		it("タイトルがあれば番号の後ろに表示する", function()
			local state = tabs.new()
			tabs.add(state, { buf = 10, title = "ログイン修正" })

			assert.are.equal("%#TabLineSel# 1 ログイン修正 %#TabLineFill#", tabs.label(state))
		end)

		it("許可待ちは赤い!、未読の完了は緑の✓を付け、元の強調に戻す", function()
			local state = tabs.new()
			tabs.add(state, { buf = 10, status = "attention" })
			tabs.add(state, { buf = 20, status = "done" })
			tabs.add(state, { buf = 30 })

			assert.are.equal(
				"%#TabLine# 1%#DiagnosticError#!%#TabLine# "
					.. "%#TabLine# 2%#DiagnosticOk#✓%#TabLine# "
					.. "%#TabLineSel# 3 %#TabLineFill#",
				tabs.label(state)
			)
		end)
	end)

	describe("clean_title", function()
		it("Claudeが付ける先頭の状態記号(✳やスピナー)を取り除く", function()
			assert.are.equal("Fix login bug", tabs.clean_title("✳ Fix login bug"))
			assert.are.equal("テスト追加", tabs.clean_title("⠐ テスト追加"))
		end)

		it("20文字を超えたら切り詰めて…を付ける", function()
			assert.are.equal(
				"あいうえおかきくけこさしすせそたちつてと…",
				tabs.clean_title("あいうえおかきくけこさしすせそたちつてとな")
			)
		end)

		it("既定のタイトルや空ならnil", function()
			assert.is_nil(tabs.clean_title("✳ Claude Code"))
			-- Claudeがタイトルを設定する前は、nvimがバッファ名(term://...)を入れている
			assert.is_nil(tabs.clean_title("term://~/.config/nvim//1234:claude --session-id x"))
			assert.is_nil(tabs.clean_title(""))
			assert.is_nil(tabs.clean_title(nil))
		end)
	end)

	describe("apply_event", function()
		it("許可要求と通知は許可待ちにする", function()
			local state = tabs.new()
			local tab = tabs.add(state, { buf = 10 })

			tabs.apply_event(state, tab, "PermissionRequest")
			assert.are.equal("attention", tab.status)

			tab.status = nil
			tabs.apply_event(state, tab, "Notification")
			assert.are.equal("attention", tab.status)
		end)

		it("作業が進んだら許可待ちを解除する", function()
			local state = tabs.new()
			local tab = tabs.add(state, { buf = 10, status = "attention" })

			tabs.apply_event(state, tab, "PostToolUse")

			assert.is_nil(tab.status)
		end)

		it("裏のタブが完了したら✓、表示中のタブなら印を付けない", function()
			local state = tabs.new()
			local background = tabs.add(state, { buf = 10 })
			local visible = tabs.add(state, { buf = 20 })

			tabs.apply_event(state, background, "Stop")
			tabs.apply_event(state, visible, "Stop")

			assert.are.equal("done", background.status)
			assert.is_nil(visible.status)
		end)
	end)

	it("表示したタブは完了の✓が消えるが、許可待ちの!は残る", function()
		local state = tabs.new()
		local done = tabs.add(state, { buf = 10, status = "done" })
		local waiting = tabs.add(state, { buf = 20, status = "attention" })
		tabs.add(state, { buf = 30 })

		tabs.activate(state, done)
		tabs.cycle(state, 1)

		assert.is_nil(done.status)
		assert.are.equal(waiting, tabs.active(state))
		assert.are.equal("attention", waiting.status)
	end)
end)
