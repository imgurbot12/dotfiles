#
# Common variables / utilities used between scripts
#

# configure scripts to exit on any command errors unless discarded
set -e

#** Variables **#

DIR=$(dirname $0)
CONFIG=`realpath "$DIR/../config"`

#** Functions **#

### Logging

_log () {
  prefix=$1
  shift
  message=$@
  echo -e "[$prefix] $message"
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

#: desc  => return 0 if substring exists in other string
#: usage => substr $substr $str
substr () {
  echo $str | grep -q $substr && return 0
  return 1
}

#: desc  => raise error if the given program cannot be found
#: usage => check_program $binary $package_name
check_program () {
  program=$1
  package=${2:-"$program"}
  if ! $program --help >/dev/null 2>&1; then
    error "program: '$package' was not found and must be installed"
  fi
  debug "package '$package' is installed"
}

#: desc  => confirm 'y/Y' or return 1
#: usage => confirm_yes $prompt
confirm_yes () {
  prompt=$1
  while true; do
    read -p "  $prompt " yn
    case $yn in
        [Yy]* ) echo ""; return 0;;
        [Nn]* ) return 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

#: desc  => request the user to run the given command as sudo
#: usage => request_sudo $command
request_sudo () {
  command=$1
  info    "user needs to run the following command as super user:"
  echo -e "\n  sudo $command \n"
  info    "afterwards you may need to run this installation script again"
  exit 1
}

#** Init **#

# ensure program is NOT running as root
if whoami | grep -E '^root$' >/dev/null; then
  error "script SHOULD NOT be run as root"
  exit 1
fi

info "checking for required binaries"
check_program git
check_program curl
