#!/bin/sh

#** Variables **#

EWW=${EWW:-"$HOME/.cargo/bin/eww"}

#** Functions **#

not () {
  [ "$1" == "true" ] && printf "false" && return 0
  printf "true"
}

bool () {
  [ "$1" == "false" ] && return 1
  return 0
}

toggle () {
  # retrieve status and flip value
  status=$($EWW get "$2")
  $EWW update "$2=$(not $status)"
  # update window based on status
  if bool "$status"; then
    echo "POP: closing widget '$1'"
    $EWW close "$1"
    return 0
  fi
  echo "POP: opening widget: '$1'"
  $EWW open "$1"
}

#** Widgets **#

calendar () {
  toggle "window_calendar" "calendar_reveal"
}

#** Init **#

case "$1" in
  "calendar")
    calendar "$2"
    ;;
  *)
    echo "invalid command. try <calendar/..>"
    ;;
esac
