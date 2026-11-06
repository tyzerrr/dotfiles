{ pkgs, ... }:
{
  xdg.configFile."gwq/config.toml".source = (pkgs.formats.toml { }).generate "gwq-config" {
    cd = {
      auto_cd_on_add = false;
      launch_shell = true;
    };
    finder.preview = true;
    naming = {
      # zsh の dev-root が host/org/repo/branch の4階層を前提にしている
      template = "{{.Host}}/{{.Owner}}/{{.Repository}}/{{.Branch}}";
      sanitize_chars = {
        "/" = "-";
        ":" = "-";
      };
    };
    ui = {
      icons = true;
      tilde_home = true;
    };
    worktree = {
      auto_mkdir = true;
      basedir = "~/worktrees";
    };
  };
}
