#
# Common variables / utilities used between scripts
#

# configure scripts to exit on any command errors unless discarded
set -e

#** Variables **#

DIR=$(dirname $0)
CONFIG="$DIR/../config"

#** Functions **#

### Logging

_log () {
  prefix=$1
  shift
  message=$@
  echo "[$prefix] $message"
}

info () {
  _log "I" "$@"
}

warn () {
  _log "W" "$@"
}

error () {
  _log "E" "$@"
  exit 1
}

debug () {
  if [ ! -z "$DEBUG" ]; then
    _log "D" " $@"
  fi
}

### Smart File Operations

_fileop () {
  cmd="$1"
  shift
  if [ ! -z "$DEBUG" ]; then
    cmd="$cmd -v"
    debug "fileop: $cmd $@"
  fi
  eval "$cmd $@"
}

copy () {
  _fileop cp "$@"
}

move () {
  _fileop mv "$@"
}

remove () {
  _fileop rm "$@"
}

makedir () {
  for arg in $@; do :; done
  if [ -d "$arg" ]; then
    debug "directory '$i' already exists"
  fi
  _fileop mkdir "$@"
}

### Additional Utilities

check_program () {
  program=$1
  package=${2:-"$program"}
  if ! $program --help 2>&1 > /dev/null; then
    error "program: '$package' was not found and must be installed"
  fi
  debug "package '$package' is installed"
}

confirm_yes () {
  prompt=$1
  while true; do
    read -p "  $prompt " yn
    case $yn in
        [Yy]* ) echo ""; break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

#** Init **#

info "checking for required binaries"
check_program git
