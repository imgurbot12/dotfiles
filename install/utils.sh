#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

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
