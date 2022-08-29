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

#: find command binary location
FIND_CMD="/usr/bin/find"

#: args used to list all files/dirs in directory
FIND_ALL=" -maxdepth 1"

#: args used to find only executables in directory
FIND_EXEC="$FIND_ALL -executable"

#: command to launch file browser
LOAD_DIR="alacritty -e joshuto --path {}"

#: command to load file
LOAD_FILE="alacritty -e nvim {}"

#: max files allowed to load in single search
MAX_FILES="30"

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
#: usage => ls $path | file_result
file_result () {
  for f in `</dev/stdin`; do
    i="$FILE_ICON"
    c='{}'
    [ -z "$EXEC_MODE" ] && c="$LOAD_FILE"
    [ -d "$f" ] && i="$DIR_ICON" && [ -z "$EXEC_MODE" ] && c="$LOAD_DIR"
    fmt_file "$f" "$i" "$(sed "s~{}~$f~g" <<< $c)"
  done
}

#: desc  => search filesystem files at the given path
#: usage => search_files $search
search_files () {
  f=`expand_user <<< "$1" | add_slash`
  # determine find arguments
  [[ $f = !* ]] && export EXEC_MODE="1" && f=${f:1} && a="$FIND_EXEC" || a="$FIND_ALL"
  # complete search
  if [ ! -d "$f" ]; then
    d=$(dirname $f)
    [ ! -d "$d" ] && echo "EWFI: skipping search on invalid dir: $d" && return 0
    s=$(basename $f)
    $FIND_CMD "$d" $a -iname "$s*" | head -n $MAX_FILES | file_result 
    return 0
  fi
  $FIND_CMD "$f" $a | head -n $MAX_FILES | file_result
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

# search_files "$@"
# exit 0

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

# process file/executable searches
if grep -qE "^[!~\./]" <<< "$ARGS"; then
  C=$(search_files "$@")
else
  C=$(search_app_cache "$@")
fi

O="$S$C)"

# echo -e $O
eww update ewfi_elements="$O"


