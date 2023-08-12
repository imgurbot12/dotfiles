#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Functions **#

# install binary via cargo (if not already installed)
binstall() {
  binary="$1"
  program="${2:-$1}"
  if has_binary $binary; then
    log_info "$program is already installed. attempting update..."
  fi
  cargo binstall $program -y
}

#** Init **#

ensure_binstall

log_info "installing shell utils"
copy_bin "wifictl"

log_info "installing rust binaries"
binstall bat
binstall rg    ripgrep
binstall fd    fd-find
binstall dust  du-dust
binstall delta git-delta
