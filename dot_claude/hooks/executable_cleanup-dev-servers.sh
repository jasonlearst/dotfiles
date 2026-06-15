#!/usr/bin/env bash
# SessionStart cleanup: remove leftover agent dev servers from prior sessions.
# Safe by construction — only touches `cc-`-prefixed tmux sessions or true
# orphans (re-parented to launchd, no controlling terminal). Never affects the
# user's own zellij/terminal sessions.

# 1. Kill leftover agent tmux sessions.
for s in $(tmux ls -F '#{session_name}' 2>/dev/null | grep '^cc-'); do
  tmux kill-session -t "$s" 2>/dev/null
done

# 2. Belt-and-suspenders: kill orphaned dev servers (PPID 1, no TTY) in case a
#    server was ever started as raw background bash instead of via tmux.
ps -axo pid,ppid,tty,command \
  | awk '$2==1 && $3=="??" && /uvicorn --reload|node .*vite|npm run dev|next dev|gunicorn.*--reload/ {print $1}' \
  | while read -r p; do kill "$p" 2>/dev/null; done

# 3. Tear down leftover agent compose stacks. Containers are daemon-managed, so
#    process/tmux cleanup never touches them — only `compose down` stops them.
#    Scoped to cc-* projects so real stacks are never affected.
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  docker compose ls --format json 2>/dev/null \
    | jq -r '.[] | select(.Name|startswith("cc-")) | .Name' \
    | while read -r proj; do docker compose -p "$proj" down -v 2>/dev/null; done
fi

exit 0
