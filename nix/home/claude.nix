{ config, dotfilesDir, ... }:
let
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.claude/${path}";
in
{
  home.file = {
    # Claude Code 自身が書き換える (/config, /permissions, # メモリ追記) ため store 外を指す
    ".claude/settings.json".source = link "settings.json";
    ".claude/mcp.json".source = link "mcp.json";
    ".claude/CLAUDE.md".source = link "CLAUDE.md";

    # ~/.claude/skills などには他の経路で入るものもあるため、ディレクトリ自体は
    # 実体のまま残してファイル単位でリンクする
    ".claude/agents" = {
      source = ../../.claude/agents;
      recursive = true;
    };
    ".claude/commands" = {
      source = ../../.claude/commands;
      recursive = true;
    };
    ".claude/skills" = {
      source = ../../.claude/skills;
      recursive = true;
    };
  };
}
