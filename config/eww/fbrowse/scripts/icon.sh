#!/bin/sh

#** Variables **#

IMG=`realpath "$(dirname $0)/../../ewfi/img"`

#** Functions **#

#: usage => iconize $path
iconize () {
  [ -d "$1" ] && e="dir" || e="${1##*.}"
  case "$e" in
    "dir")
      echo "$IMG/dir-icon.png"
      ;;
    *)
      echo "$IMG/default-logo.png"
      ;;
  esac
}

#** Init **#

echo "'$(iconize $1)' '$1' '$(basename $1)'"

