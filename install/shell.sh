#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Init **#

case "$1" in
  "fish")
    ensure_program fish
    copy_config "fish"
    log_info "fish configuration installed"
    ;;
  "bash")
    ensure_program bash
    copy_home ".shellrc"
    log_info "bash configuration installed"
    ;;
  "xonsh")
    ensure_program xonsh
    copy_home ".xonshrc"
    copy_config "xonsh"
    log_info "xonsh configuration installed "
    ;;
  *)
    echo "usage: $0 fish|bash|xonsh" && exit 1
    ;;
esac
