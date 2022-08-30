#!/bin/sh

#
# Manage/Render File-Browser Favorites
#

#** Variables **#

#: eww binary instance
EWW="$HOME/.cargo/bin/eww"

#: db cache of favorites
FAV_DB="$HOME/.cache/fbrowse-favs.tsv"

#** Functions **#

#: usage => find $col $search
find () {
  [ $# -ne 2 ] && echo 'find needs $col and $search args' && return 1
  awk -F '\t' "\$$1~/^'$2'$/ {print NR}" $FAV_DB
}

#: usage => add $path
add () {
  [ ! -e "$1" ] && echo "invalid favorite: '$1'" && return 1
  [ -d "$1" ] && mime="dir" || mime="${1##*.}"

  name=`basename $1`
  lno=$(find 2 "$name")
  [ -n "$lno" ] && echo "BROWSE: favorite already exists: '$name'" && return 1

  printf "'$1'\t'$name'\t'$mime'\n" >> $FAV_DB
  echo "BROWSE: added '$name' to favorites"
}

#: usage => del $name
del () {
  n=`find 2 "$1"`
  [ ! -n "$n" ] && echo "BROWSE: no such favorite: '$1'" && return 1
  sed -i "${n}d" $FAV_DB
  echo "BROWSE: removed '$1' from favorites"
}

#: usage => list
list () {
  cat $FAV_DB
}

#: list => list_results
list_results () {
  echo '(box :class "bookmark-wrapper" :orientation "v" '
  awk -F '\t' '{print "  (fbrowse_bookmark :path " $1 " :name " $2 ")"}' $FAV_DB
  echo ")"
}

#** Init **#

case "$1" in
  "a"|"add")
    add "$2"
    ;;
  "f"|"find")
    find 2 "$2"
    ;;
  "d"|"del")
    del "$2"
    ;;
  "l"|"list")
    list
    ;;
  "lr"|"list-results")
    list_results
    ;;
  "ur"|"update-results")
    $EWW update fbrowse_bookmarks="$(list_results)"
    ;;
  *)
    echo "invalid command. try <list/find/add/del>"
    ;;
esac
