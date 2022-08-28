#!/bin/sh

#** Variables **#

#: eww executable path
EWW="$HOME/.cargo/bin/eww"

#: application results cache
CACHE_FILE="$HOME/.cache/ewfi_elements"

#: quit sequence to close window
QUIT_CMD=":q"

#** Functions **#

#: desc  => search desktop apps for the given text
#: usage => search_apps $search
search_cache () {
  cat $CACHE_FILE    \
  | cut -f1-3 \
  | grep -in "$1"    \
  | cut -d ':' -f1   \
  | xargs -I '{}' awk 'NR=={}{print;exit}' $CACHE_FILE \
  | awk -F "\t" '{print "(search_result :image " $4 " :app " $1 " :desc " $2 " :cmd " $5 " )"}'
}

#** Init **#

ARGS="$@"

# handle quit command
if [ "$ARGS" == "$QUIT_CMD" ]; then
  echo "EWFI: executing quit command"
  $EWW close window_ewfi
  exit 0
fi

# skip any search when passed a command
if grep -qE "^:.*" <<< "$ARGS"; then
  echo "EWFI: skipping search on command: '$ARGS'"
  exit 0
fi


s="(box :class 'search-result-list' :orientation 'v' :space-evenly false "
m=$(search_cache "$@")
o="$s$m)"

# echo -e $o
eww update ewfi_elements="$o"


