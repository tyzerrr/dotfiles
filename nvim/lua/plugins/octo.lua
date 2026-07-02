return {
	"tyzerrr/octo.nvim",
	-- ローカルのフォーク（未pushの変更を含む）を直接読み込む。
	-- これを外すとlazyがupstream(pwntester)をcloneして変更が反映されない。
	dir = "/Users/t-b-araki/ghq/github.com/tyzerrr/octo.nvim",
	cmd = "Octo",
	opts = {
		-- or "fzf-lua" or "snacks" or "default"
		picker = "snacks",
		-- bare Octo command opens picker of commands
		enable_builtin = true,
		reviews = {
			-- 新タブではなく現在のウィンドウを左右分割してDiffを表示する。
			-- これによりClaude等の他splitがそのまま保持される。
			layout = "current",
		},
	},
	keys = {
		{ "<leader>op", "<CMD>Octo pr list<CR>", desc = "List Github PullRequest" },
		-- 全リポジトリ横断（GitHub検索API）
		{ "<leader>oM", "<CMD>Octo search is:pr is:open author:@me<CR>", desc = "List my open PRs (all repos)" },
		{
			"<leader>oR",
			"<CMD>Octo search is:pr is:open review-requested:@me<CR>",
			desc = "PRs requesting my review (all repos)",
		},
		-- カレントリポジトリ限定（Octo pr search は自動で現在のremoteに絞られる）
		{ "<leader>om", "<CMD>Octo pr search author=@me is=open<CR>", desc = "My open PRs (current repo)" },
		{
			"<leader>or",
			"<CMD>Octo pr search review-requested=@me is=open<CR>",
			desc = "PRs requesting my review (current repo)",
		},
		-- カレントブランチに紐づくPR
		{ "<leader>ob", "<CMD>Octo pr<CR>", desc = "Open PR for current branch" },
		{ "<leader>ov", "<CMD>Octo review<CR>", desc = "Review current branch PR (diff + comments)" },
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"folke/snacks.nvim",
	},
}
