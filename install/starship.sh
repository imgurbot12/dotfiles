#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

# run fonts install ahead of time
. "$(dirname $0)/nerdfonts.sh"

#** Init **#

ensure_binstall

log_info "installing starship or updating binary..."
cargo binstall starship -y

log_info "installing startheme tool and extra themes"
copy_bin "startheme"
copy_config "starship"
