#!/usr/bin/env bash
# Fish shell-like path compression for tmux session names
# Keep last 2 components full, shorten the rest to first char

path="$1"

# Replace $HOME with ~
tilde='~'
path="${path/#$HOME/$tilde}"

IFS='/' read -ra parts <<< "$path"
len=${#parts[@]}

if [ "$len" -le 3 ]; then
  echo "$path"
  exit 0
fi

result=""
for ((i = 0; i < len; i++)); do
  if [ "$i" -gt 0 ]; then
    result+="/"
  fi
  if [ "$i" -ge $((len - 2)) ]; then
    result+="${parts[$i]}"
  else
    result+="${parts[$i]:0:1}"
  fi
done

echo "$result"
