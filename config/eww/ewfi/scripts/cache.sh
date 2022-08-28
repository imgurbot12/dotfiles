#!/bin/sh

#: find executable
FIND="/usr/bin/find"

#: language to complete search with
LANGUAGE="us"

#: folders to find desktop files
FILE_PATHS="/usr/share/applications $HOME/.local/share/applications"

#: folders to find icon files
ICON_PATHS="/usr/share/icons $HOME/.local/share/icons"

#: application results cache
CACHE_FILE="$HOME/.cache/ewfi_elements"

#: default logo location
DEFAULT_LOGO=$(realpath "$(dirname $0)/../img/default-logo.png")

#: normal template for standard command
NORMAL_CMD="{}"

#: terminal command template
TERMINAL_CMD="alacritty -e {}"

#** Functions **#

#: desc  => retrieve single attribute from `.desktop` file
#: usage => get_attr "$file_contents" "Attribute"
get_attr () {
  if [ "$LANGUAGE" != "us" ]; then
    out=$(grep -Eo "^$2\[$LANGUAGE\]=.+" <<< "$1")
    [ -n "$out" ] && echo "$out" | cut -d '=' -f2 | head -n 1 && return 0
  fi
  grep -Eo "^$2=.+" <<< "$1" | cut -d '=' -f2 | head -n 1
}

#: desc  => return 0 if given string contains substring
#: usage => contains "$str" "$substr"
contains () {
  echo "$1" | grep -Ei "$2" >/dev/null 2>&1 && return 0
  return 1
}

#: desc  => return 0 if given string contains (true/1)
#: usage => istrue "$str"
istrue () {
  contains "$1" "ue" && return 0
  contains "$1" "1"  && return 0
  return 1
}

#: desc  => retrieve icon from given .desktop content
#: usage => get_icon "$content"
get_icon () {
  name=$(get_attr "$content" "Icon")
  $FIND $ICON_PATHS -iname "$name*" 2>/dev/null | head -n 1
}

#: desc  => retrieve command to execute application
#: usage => get_command "$content" 
get_command () {
  # determine base command
  exec=$(get_attr "$content" "Exec")
  term=$(get_attr "$content" "Terminal")
  base=$NORMAL_CMD
  istrue "$term" && base="$TERMINAL_CMD"
  # format command
  echo $exec | sed -e 's#%\w##' | xargs -I '{}' echo "$base"
}

#: desc  => search desktop apps for the given text
#: usage => cache_apps $search "$renderfunc"
cache_apps () {
  for file in $($FIND $FILE_PATHS -type f -iname "*.desktop"); do
    content=$(cat $file)
    # get attributes from desktop file
    name=$(get_attr "$content" "Name")
    generic=$(get_attr "$content" "GenericName")
    comment=$(get_attr "$content" "Comment")
    icon=$(get_icon "$content")
    exec=$(get_command "$content")
    # skip if name is empty (bad .desktop file) 
    [ -z "$name" ] && continue
    # fill default icon if icon doesn't exist
    if [ ! -f "$icon" ]; then
      icon=$DEFAULT_LOGO
    fi
    # generate tsv entry
    echo -e "'$name'\t'$generic'\t'$comment'\t'$icon'\t'$exec'"
  done
}

cache_valid () {
  EXPR=$(expr '8 * 3600')
  test $(stat -c %Y -- "$CACHE_FILE") -gt $(($(date +%s) - $EXPR)) && return 0
  return 1
}

#** Init **$

# skip cache update if there are no args, file exists, and it's not too old
if [ "$#" -eq 0 ] && [ -f "$CACHE_FILE" ] && cache_valid; then
  echo "EWFI: skipping cache update"
  exit 0
fi

# cache_apps
echo "EWFI: updating app cache"
cache_apps | sort -k 1 > $CACHE_FILE
echo "EWFI: app cache updated"
