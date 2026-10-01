-- AIエージェントの変更を左右分割のdiffでレビューする（自作: tyzerrr/agent-review.nvim）。
-- 右（作業ツリー）でLSPジャンプすると、左（base）が同じファイルに追従する。
-- キーはプラグインのデフォルト（<leader>dr/dR/dl/dh, ]f/[f, base側の q/<C-l>）をそのまま使う。
return {
	dir = "~/ghq/github.com/tyzerrr/agent-review.nvim",
	name = "agent-review.nvim",
	-- :Telescope agent_review を使えるよう、起動後にruntimepathへ載せておく（plugin/は軽量）。
	event = "VeryLazy",
	opts = {},
}
