#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.color=0x887aa2f7 label.shadow.drawing=on icon.shadow.drawing=on background.border_width=2 background.border_color=0xAA7aa2f7
else
  sketchybar --set $NAME background.color=0x4424283b label.shadow.drawing=off icon.shadow.drawing=off background.border_width=0
fi