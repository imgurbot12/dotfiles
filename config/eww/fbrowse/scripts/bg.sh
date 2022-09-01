#!/bin/sh

echo "BROWSE: spawning command '$@' in bg"
exec "$(dirname $0)/$@" &
disown
