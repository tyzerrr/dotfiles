# Set prefix C-g
set-option -g prefix C-g


# Enable mouse to scroll
set-option -g mouse on

# Set vi-mode
set -g mode-keys vi

# Enable 24-bit color. DONT FORGET to add [export TERM="tmux-256color"] to .zshrc.
set-option -g default-terminal "tmux-256color"
set-option -ga terminal-overrides ",*256col*:Tc"

# Rebase index
set -g base-index 1

# History limit
set -g history-limit 10000

set -g renumber-windows on

set -g set-clipboard on
