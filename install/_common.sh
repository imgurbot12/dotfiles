#
# Common libraries for installation scripts
#

# confgure scripts to exit on any command errors unless explicitly handled
set -e

#** Variables **#

#: loglevel configuration 
LOGLEVEL=${LOGLEVEL:-1}

#: dirpath of self
DIR=$(dirname $0)

#: dotfiles directory
DOTFILES=`realpath "$DIR/../dotfiles"`

#: patches directory
PATCHES=`realpath "$DIR/../patches"`

#** Functions **#

### Logging

log_write () {
  printf "[$1] $2\n"
}

log_info () {
  [ $LOGLEVEL -gt 1 ] && return 0
  log_write "INFO" "$@"
}

log_warn () {
  [ $LOGLEVEL -gt 2 ] && return 0
  log_write "WARN" "$@"
}

log_error () {
  [ $LOGLEVEL -gt 3 ] && return 0
  log_write "ERROR" "$@"
}

log_debug () {
  [ $LOGLEVEL -gt 0 ] && return 0
  log_write "DEBUG" "$@"
}

### Smart File Operations

file_do () {
  [ ! -n "$SUDO" ]    && cmd="$1"  || cmd="sudo $1"
  [ $LOGLEVEL -gt 0 ] && args="$2" || args="-v $2"
  log_debug "file-op: \`$cmd $args\`"
  eval "$cmd $args"
}

file_copy () {
  file_do "cp" "$@"
}

file_move () {
  file_do "mv" "$@"
}

file_remove () {
  file_do "rm" "$@"
}

file_mkdir () {
  file_do "mkdir" "$@" 
}

### Copy Utilities

#: desc  => copy file-structure from one tree to another
#: usage => $cfg-base $real-base $path
_copy () {
  file=$(echo $3 | sed 's~^/~~')
  src="${1%%/}/$file"
  dest="${2%%/}/${file%%.}"
  dest_dir=$(dirname $dest)
  [ -d "$dest_dir" ] || file_mkdir "-p $dest_dir"
  file_copy "-rf '$src' '$dest'"
}

#: desc  => copy binary to $HOME/.local/bin/
#: usage => $binary-name
copy_bin() {
  _copy "$DOTFILES/local/bin" "$HOME/.local/bin" "$1"
}

#: desc  => copy file/directory tree into dotconfig dir
#: usage => $path
copy_config() {
  _copy "$DOTFILES/config" "$HOME/.config" "$1"
}

#: desc  => copy file/directory tree into home dir
#: usage => $path 
copy_home() {
  _copy "$DOTFILES" "$HOME" "$1"
}

### Additional Utilities

#: desc  => return 0 if binary is found
#: usage => $binary
has_binary () {
  which $1 >/dev/null 2>&1 && return 0
  return 1
}

#: desc  => raise error and exit if the requested binary is missing
#: usage => $binary $package-name
ensure_program () {
  pkg=${2:-"$1"}
  if ! has_binary $1; then
    log_error "program: '$pkg' was not found and must be installed"
    return 1
  fi
  log_debug "package '$pkg' is installed"
}

#: desc => ensure cargo-binstall is installed
ensure_binstall() {
  ensure_program cargo rust
  if ! cargo binstall --help >/dev/null 2>&1; then
    log_error "cargo binstall not detected. cannot install."
    exit 1
  fi
}

#: desc  => get version of requested binary if it exists
#: usage => $binary
get_version () {
  $1 --version | grep -oE '[0-9]\.([0-9]\.?)+' || true
}

#: desc  => confirm 'y/Y' or return 1
#: usage => $prompt
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

#** Init **#

if whoami | grep -qE '^root$' && ! echo "$@" | grep -q '\-\-confirm'; then
  log_warn "script is blocked to run as root by default"
  log_warn "include '--confirm' in arguments to override block"
  exit 1
fi

log_info "checking for required programs"
ensure_program git
ensure_program curl
