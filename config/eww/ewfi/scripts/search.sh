#!/bin/sh

#** Variables **#

IMG=`realpath "$(dirname $0)/../img"`

#: eww executable path
EWW="$HOME/.cargo/bin/eww"

#: application results cache
CACHE_FILE="$HOME/.cache/ewfi_elements"

#: directory path icon
DIR_ICON="$IMG/dir-icon.png"

#: file path icon
FILE_ICON="$IMG/file-icon.png"

#: command used to list files in directory
LIST_DIR="ls"

#: command to launch file browser
LOAD_DIR="alacritty -e joshuto --path {}"

#: command to load file
LOAD_FILE="alacritty -e nvim {}"

#: max files allowed to load in single search
MAX_FILES="20"

#: quit sequence to close window
QUIT_CMD=":q"

#** Functions **#

alias expand_user="sed 's,~,$HOME,1'"
alias rem_slash='sed "/\/$/s/\/$//"'
alias add_slash='sed "/\/$/!s/$/\//"'
alias fmt_result="awk -F '\t' '{print \"(search_result :image \" \$4 \" :app \" \$1 \" :desc \" \$2 \" :cmd \" \$5 \" )\"}'"

#: desc  => simplified fmt_result for formatting file entries
#: usage => fmt_file $app $image $command
fmt_file () {
  echo -e "'$1'\t''\t''\t'$2'\t'$3'" | fmt_result
}

#: desc  => list icon to use for specified file 
#: usage => ls $path | file_icon $path
file_icon () {
  b=`add_slash <<< "${1:-''}"`
  for p in `</dev/stdin`; do
    f="$b$p"
    if [ ! -d "$f" ]; then
      fmt_file "$f" "$FILE_ICON" "$(sed "s~{}~$f~g" <<< $LOAD_FILE)"
      continue
    fi
    fmt_file "$f" "$DIR_ICON" "$(sed "s~{}~$f~g" <<< $LOAD_DIR)"
  done
}

#: desc  => search filesystem files at the given path
#: usage => search_files $search
search_files () {
  if [ ! -d "$1" ]; then
    d=$(dirname $1)
    [ ! -d "$d" ] && echo "EWFI: skipping search on invalid dir: $d" && return 0
    s=$(basename $1)
    $LIST_DIR "$d" | grep -i "^$s" | head -n $MAX_FILES | file_icon "$d"
    return 0
  fi
  $LIST_DIR "$1" | head -n $MAX_FILES | file_icon "$1"
}

#: desc  => search desktop apps for the given text
#: usage => search_app_cache $search
search_app_cache () {
  cat $CACHE_FILE  \
  | cut -f1-3      \
  | grep -in "$1"  \
  | cut -d ':' -f1 \
  | xargs -I '{}' awk 'NR=={}{print;exit}' $CACHE_FILE \
  | fmt_result
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

S="(box :class 'search-result-list' :orientation 'v' :space-evenly false "

# process file searches
if grep -qE "^[~\./]" <<< "$ARGS"; then
  dir=`echo $@ | expand_user`
  C=$(search_files "$dir")
else
  C=$(search_app_cache "$@")
fi

O="$S$C)"

# echo -e $O
eww update ewfi_elements="$O"


