# Tokyo Night status bar
#
# Palette:
#   fg:       #c0caf5
#   blue:     #7aa2f7 (active window)
#   comment:  #565f89 (inactive window)
#   pink:     #ff79c6 (session name)

# --- Status bar position & style ---
set -g status-position bottom
set -g status-style "bg=#24283b,fg=#c0caf5"
set -g status-justify absolute-centre

# --- Left: compressed session name ---
set -g status-left-length 40
set -g status-left "#[fg=#7aa2f7,bold]session: #(~/.config/tmux/scripts/compress_path.sh '#{session_name}') "

# --- Right: empty ---
set -g status-right ""

# --- Window list ---
set -g window-status-format "#[fg=#565f89] #I:#W "
set -g window-status-current-format "#[fg=#7aa2f7,bold] #I:#W "
set -g window-status-separator ""

# --- Pane border ---
set -g pane-border-style "fg=#565f89"
set -g pane-active-border-style "fg=#7aa2f7"

# --- Message style ---
set -g message-style "bg=default,fg=#c0caf5"
