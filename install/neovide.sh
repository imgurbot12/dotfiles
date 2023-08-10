#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Variables **#

#: download link for neovide download
NEOVIDE="https://github.com/neovide/neovide/releases/latest/download/neovide.tar.gz"

#** Init **#

# download and unpackage bundled binary
bundle="/tmp/neovide.tar.gz"
target="/tmp/neovide"
if [ ! -f $target ]; then
  # download bundle
  if [ ! -f $bundle ]; then
    log_info "downloading latest neovide release"
    curl -L $NEOVIDE -o $bundle
  fi
  # unpackage bundle
  if [ ! -f "$target" ]; then
    /bin/sh -c "cd /tmp/ && tar xvf $bundle" >/dev/null 2>&1
  fi
  if [ ! -f "$target" ]; then
    log_error "unable to locate neovide binary after unbundling"
    exit 1
  fi
fi

# compare downloaded version to existing version
NEW_VERSION="$(get_version $target)"
CURRENT_VERSION="$(get_version neovide)"
if [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
  log_warn "neovide is already up to date. cancelling installation."
  file_remove "-f $target $bundle" && return 0
fi

# move target to final binary installation dest
dest="/usr/local/bin/neovide"
log_info "moving neovide to '$dest' (as root)"
SUDO=1 file_move "-f $target $dest"
