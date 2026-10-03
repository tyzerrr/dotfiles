-- Claude CLIのセッションIDまわり。各タブにIDを割り当てて起動しておくことで、
-- 後から `--resume <id> --fork-session` で文脈を引き継いだタブを作れるようにする。
local M = {}

function M.uuid()
	local bytes = { vim.uv.random(16):byte(1, 16) }
	-- RFC 4122 v4: version=4, variant=10xx
	bytes[7] = bit.bor(bit.band(bytes[7], 0x0f), 0x40)
	bytes[9] = bit.bor(bit.band(bytes[9], 0x3f), 0x80)
	return string.format("%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x", unpack(bytes))
end

function M.build_args(opts)
	local args = "--session-id " .. opts.session_id
	if opts.fork_from then
		return "--resume " .. opts.fork_from .. " --fork-session " .. args
	end
	return args
end

function M.parse_args(cmd_string)
	return {
		session_id = cmd_string:match("%-%-session%-id%s+(%S+)"),
		forked = cmd_string:find("--fork-session", 1, true) ~= nil,
	}
end

-- Claude Codeのhookがイベントごとに上書きする「session_id<TAB>イベント名<TAB>対象パス」。
-- /clearや/resumeでIDが変わっても追従でき、裏のタブの状態やdiffの発信元の判定にも使う。
function M.read_status(path)
	if vim.fn.filereadable(path) == 0 then
		return nil
	end
	local line = vim.fn.readfile(path, "", 1)[1]
	if not line or line == "" then
		return nil
	end
	local fields = vim.split(line, "\t", { plain = true })
	return {
		session_id = fields[1],
		event = fields[2],
		path = fields[3] ~= "" and fields[3] or nil,
	}
end

return M
