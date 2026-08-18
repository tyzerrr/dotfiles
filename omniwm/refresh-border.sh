#!/bin/zsh

# OmniWM 0.6.0 workaround:
# Re-focus the visible window after an active-workspace change, and after a
# mouse resize settles, so the managed focus border is restacked and resized
# immediately instead of waiting for another mouse click.

set -u

omniwmctl_path="/opt/homebrew/bin/omniwmctl"
jq_path="/Users/araki/.nix-profile/bin/jq"

if [[ ! -x "$omniwmctl_path" || ! -x "$jq_path" ]]; then
  exit 0
fi

if [[ "${1:-}" != "--watch" ]]; then
  # The watch event is intentionally consumed by the parent watcher. A short
  # delay lets OmniWM finish its workspace focus handoff before querying it.
  sleep 0.15
  event_workspace_number="$($jq_path -r '.result.payload.workspace.number // empty' 2>/dev/null)"
  [[ -n "$event_workspace_number" ]] || exit 0

  integer attempt=1
  while (( attempt <= 5 )); do
    focused_window_id="$($omniwmctl_path query windows --format json 2>/dev/null \
      | $jq_path -r --argjson workspace "$event_workspace_number" '
          .result.payload.windows[]
          | select(.isFocused == true and .isVisible == true)
          | select(.workspace.number == $workspace)
          | .id
        ' \
      | /usr/bin/head -n 1)"

    if [[ -n "$focused_window_id" ]]; then
      "$omniwmctl_path" window focus "$focused_window_id" >/dev/null 2>&1
      exit 0
    fi

    sleep 0.1
    (( attempt++ ))
  done
  exit 0
fi

lock_dir="/private/tmp/omniwm-border-refresh-watch.lock"
if ! /bin/mkdir "$lock_dir" 2>/dev/null; then
  exit 0
fi

poller_pid=""
cleanup() {
  if [[ -n "$poller_pid" ]]; then
    kill "$poller_pid" >/dev/null 2>&1 || true
  fi
  /bin/rmdir "$lock_dir" >/dev/null 2>&1 || true
}
trap cleanup EXIT

while ! "$omniwmctl_path" ping >/dev/null 2>&1; do
  /bin/sleep 2
done

poll_focused_border() {
  local previous_state=""
  local pending_state=""
  local focused_state=""
  local focused_window_id=""
  typeset -F pending_since=0.0
  typeset -F now=0.0

  while true; do
    focused_state="$($omniwmctl_path query focused-window --format json 2>/dev/null \
      | $jq_path -r '
          .result.payload.window as $window
          | if $window == null then ""
            else [
              $window.id,
              ($window.frame.x // ""),
              ($window.frame.y // ""),
              ($window.frame.width // ""),
              ($window.frame.height // "")
            ] | @tsv
            end
        ')"

    if [[ -z "$focused_state" ]]; then
      previous_state=""
      pending_state=""
      /bin/sleep 0.25
      continue
    fi

    # Establish a baseline without stealing focus at watcher startup.
    if [[ -z "$previous_state" ]]; then
      previous_state="$focused_state"
      /bin/sleep 0.25
      continue
    fi

    if [[ "$focused_state" == "$previous_state" ]]; then
      pending_state=""
    elif [[ "$focused_state" != "$pending_state" ]]; then
      pending_state="$focused_state"
      pending_since="$EPOCHREALTIME"
    else
      now="$EPOCHREALTIME"
      if (( now - pending_since >= 0.25 )); then
        focused_window_id="${focused_state%%$'\t'*}"
        if "$omniwmctl_path" window focus "$focused_window_id" >/dev/null 2>&1; then
          previous_state="$focused_state"
          pending_state=""
        fi
      fi
    fi

    /bin/sleep 0.25
  done
}

# Interactive resize updates app frames directly, so also keep a low-frequency
# frame poller. It debounces the change and re-focuses only once after resizing
# stops, avoiding focus churn while the mouse is being dragged.
poll_focused_border &
poller_pid=$!

while true; do
  "$omniwmctl_path" watch active-workspace --no-send-initial \
    --exec "$0" >/dev/null 2>&1
  /bin/sleep 2
done
