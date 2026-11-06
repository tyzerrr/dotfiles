# 旧 zsh/omp.json を Nix に移したもの
{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
      upgrade = {
        notice = false;
      };
      terminal_background = "p:grey";
      palette = {
        grey = "#454758";
        lavender = "#AE8FE7";
        white = "#FFFFFF";
        text = "#494D64";
      };
      blocks = [
        {
          alignment = "left";
          segments = [
            {
              foreground = "#FFEE58";
              style = "plain";
              template = "  ";
              type = "root";
            }
            {
              background = "p:grey";
              foreground = "p:white";
              powerline_symbol = "";
              properties = {
                style = "unique";
              };
              style = "powerline";
              template = " {{ .Path }} ";
              type = "path";
            }
            {
              background = "p:lavender";
              foreground = "p:text";
              powerline_symbol = "";
              style = "powerline";
              template = " {{ .HEAD }} ";
              properties = {
                branch_icon = " ";
                cherry_pick_icon = " ";
                commit_icon = " ";
                fetch_status = false;
                fetch_upstream_icon = false;
                merge_icon = " ";
                no_commits_icon = " ";
                rebase_icon = " ";
                revert_icon = " ";
                tag_icon = " ";
              };
              type = "git";
            }
            {
              background = "#ff8080";
              foreground = "#ffffff";
              powerline_symbol = "";
              style = "powerline";
              template = "  ";
              type = "status";
            }
          ];
          type = "prompt";
        }
        {
          type = "rprompt";
          alignment = "right";
          segments = [
            {
              type = "time";
              style = "plain";
              foreground = "p:lavender";
              properties = {
                time_format = "Mon Jan _2 15:04:05 MST";
              };
            }
          ];
        }
      ];
      final_space = true;
      version = 3;
    };
  };
}
