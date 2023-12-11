#!/usr/bin/env sh

# Ensure `~/.local` is included in path
LOCALPATH="$HOME/.local/bin"
if ! echo '$PATH' | grep "$LOCALPATH" 2>&1 >/dev/null; then
  PATH="$PATH:$LOCALPATH"
fi

# Terminate already running bar instances
killall -q waybar

# Wait until the processes have been shut down
while pgrep -x waybar >/dev/null; do sleep 1; done

# Launch main
exec waybar
