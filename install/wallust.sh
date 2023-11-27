#!/bin/sh

. "$(dirname $0)/_common.sh"

ensure_binstall

log_info "installing wallust"
binstall wallust

log_info "copying wallust config"
copy_config wallust
