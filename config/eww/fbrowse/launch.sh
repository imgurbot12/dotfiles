#!/bin/sh

#** Variables **#

#: eww executable location
EWW="$HOME/.cargo/bin/eww"

#: scripts directory
SCRIPTS="$(dirname $0)/scripts"

#** Functions **#

#: usage => load $var $command
load () {
  value=$($EWW get $1 2>/dev/null)
  [ ! -n "$value" ] && eval "$2"
}

#** Init **#

# DEBUG: close window if already open
$EWW close window_fbrowse 2>/dev/null

# render favorites / files / navbar / etc...
load fbrowse_items     "$SCRIPTS/files.sh update-results $HOME"
load fbrowse_bookmarks "$SCRIPTS/favs.sh update-results"

# launch window
$EWW open window_fbrowse
