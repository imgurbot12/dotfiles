#!/bin/sh

#
# Swap Starship themes with ease
#

#** Variables **#

#: directory contianing all current themes
THEMES_DIR="$HOME/.config/starship"

#: final destination for active theme
STARSHIP_CFG="$HOME/.config/starship.toml"

#** Functions **#

#: desc => list available themes
list_themes () {
  ls "$THEMES_DIR/." | awk -F. '/.toml$/ {print NR ". " $1}'
}

#: desc => ensure theme exists
is_theme () {
  [ -f "$THEMES_DIR/$1.toml" ] && return 0 || return 1
}

#: desc => print contents of theme
get_theme () {
  [ $# -ne 1 ] && echo "usage: $(basename $0) get <theme>" && exit 1
  [ ! -f "$THEMES_DIR/$1.toml" ] && echo "invalid theme: $1" && exit 1
  cat "$THEMES_DIR/$1.toml"
}

#: desc => set the specified starship theme
set_theme () {
  [ $# -ne 1 ] && echo "usage: $(basename $0) set <theme>" && exit 1
  [ ! -f "$THEMES_DIR/$1.toml" ] && echo "invalid theme: $1" && exit 1
  echo "setting starship theme: $1"
  cat "$THEMES_DIR/$1.toml" > $STARSHIP_CFG && echo "done"
}

#** Init **#

case "$1" in
  'l'|'list') list_themes    ;;
  'g'|'get')  get_theme "$2" ;;
  's'|'set')  set_theme "$2" ;;
  *)
    echo "invalid command. try <list/set/get>"
    exit 1
    ;;
esac
