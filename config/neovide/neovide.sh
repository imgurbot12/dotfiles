#!/bin/sh

BIN="/opt/neovide/neovide"

if [ ! -f "$BIN" ]; then
  echo "neovide binary not found. cannot launch"
  exit 1
fi

# launch as normal if help flag is present
if echo "$@" | grep '--help' >/dev/null 2>&1; then
  $BIN $@
  return
fi

# launch neovide binary and save pid
nohup $BIN $@ >/dev/null 2>&1 &
