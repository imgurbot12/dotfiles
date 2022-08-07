#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Functions **#

check_pyenv () {
  if pyenv root > /dev/null; then
    error "pyenv already installed"
  fi
}

install_pyenv () {
  info "running pyenv using installer script"
  if curl https://pyenv.run | bash; then
    info "installer completed successfully"
    warn "ensure bash profile is installed to link pyenv to \$PATH"
  fi
}

#** Init **#

check_program bash

case "$1" in
  "install")
    check_pyenv
    install_pyenv
    ;;
  *)
    error "invalid command. use <install/...>"
    ;;
esac
