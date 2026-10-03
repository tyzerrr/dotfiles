-- Claudeターミナルのタブ一覧。Neovim APIに依存しない純粋なロジックだけを置き、単体テストしやすくする。
local M = {}

function M.new()
	return { items = {}, active = nil }
end

local function index_of(state, tab)
	for i, item in ipairs(state.items) do
		if item == tab then
			return i
		end
	end
end

function M.add(state, fields)
	local tab = vim.deepcopy(fields)
	table.insert(state.items, tab)
	state.active = tab
	return tab
end

-- 見たタブの「完了」は既読にする。許可待ちは操作するまで解消しないので残す。
function M.activate(state, tab)
	state.active = tab
	if tab and tab.status == "done" then
		tab.status = nil
	end
end

local attention_events = { PermissionRequest = true, Notification = true }

function M.apply_event(state, tab, event)
	if attention_events[event] then
		tab.status = "attention"
	elseif event == "Stop" then
		tab.status = tab ~= state.active and "done" or nil
	else
		tab.status = nil
	end
end

local max_title = 20

function M.clean_title(raw)
	if not raw then
		return nil
	end
	-- Claudeはタイトル先頭に状態記号(待機中の✳/✻、作業中の点字スピナー)を付ける
	local title = vim.trim(vim.fn.substitute(raw, [[\v^[⠀-⣿✳✻·* ]+]], "", ""))
	if title == "" or title == "Claude Code" or vim.startswith(title, "term://") then
		return nil
	end
	if vim.fn.strchars(title) > max_title then
		title = vim.fn.strcharpart(title, 0, max_title) .. "…"
	end
	return title
end

function M.active(state)
	return state.active
end

function M.remove(state, tab)
	local idx = index_of(state, tab)
	if not idx then
		return
	end
	table.remove(state.items, idx)
	if state.active == tab then
		-- 閉じた位置にあるタブ(=元の右隣)を優先し、末尾だった場合のみ左隣に寄せる。
		state.active = state.items[idx] or state.items[idx - 1]
	end
end

function M.cycle(state, delta)
	local n = #state.items
	local idx = index_of(state, state.active)
	if n == 0 or not idx then
		return
	end
	M.activate(state, state.items[(idx - 1 + delta) % n + 1])
end

function M.find_by_buf(state, buf)
	for _, item in ipairs(state.items) do
		if item.buf == buf then
			return item
		end
	end
end

function M.label(state)
	local parts = {}
	for i, item in ipairs(state.items) do
		local hl = item == state.active and "%#TabLineSel#" or "%#TabLine#"
		local text = " " .. i .. (item.forked and "⑂" or "") .. (item.title and " " .. item.title or "")
		local marker = ""
		if item.status == "attention" then
			marker = "%#DiagnosticError#!" .. hl
		elseif item.status == "done" then
			marker = "%#DiagnosticOk#✓" .. hl
		end
		table.insert(parts, hl .. text .. marker .. " ")
	end
	return table.concat(parts) .. "%#TabLineFill#"
end

return M
