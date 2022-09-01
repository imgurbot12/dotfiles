#!/bin/sh

#
# List/Render directory contents
# 

. "$(dirname $0)/icon.sh" ":l"

#** Variables **#

#: eww binary
EWW="$HOME/.cargo/bin/eww"

#: list directory function
LIST_DIR="/usr/bin/find"

#: arguments to pass to find
ARGS=" -maxdepth 1"

#: arguments to pass when hiding hidden files
ARGS_HIDDEN="$ARGS -not -path '*/.*'"

#** Functions **#

#: functionify iconize script
iconize="$(dirname $0)/icon.sh"

#: usage => <cmd> | fmt_file
fmt_file () {
  for f in `</dev/stdin`; do
    fileinfo $f
  done
}

#: usage => list $dir
list () {
  [ ! -d "$1" ] && echo "BROWSE: list invalid directory: '$1'" && return 1
  [ ! -n "$S_HIDDEN" ] && a=$ARGS_HIDDEN || a=$ARGS
  eval "$LIST_DIR '$1' $a | tail -n +2 " | fmt_file
}

#: usage => list_results $dir
list_results () {
  echo "(box :class 'item-list' :orientation 'v'"
  list "$1" | awk '{print "  (fbrowse_item :image " $1 " :path " $2 " :name " $3 ")"}'
  echo ")"
}

#** Init **#

[ $# -ne 2 ] && echo 'command needs two arguments: $cmd $dir' && exit 1
p=`realpath "$2"`
case "$1" in
  "l"|"list")
    list "$p"
    ;;
  "lr"|"list-results")
    list_results "$p"
    ;;
  "ur"|"update-results")
    $EWW update fbrowse_path="$p"
    $EWW update fbrowse_files="$(list_results $p)"
    ;;
  *)
    echo "invalid command. try <list/list-results/update-results>"
    ;;
esac
