#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables **#

#: online script resource to install rustup
RUSTUP="https://sh.rustup.rs"

#: assumed environment location for cargo source
CARGOENV="$HOME/.cargo/env"

#** Functions **#

export_cargo () {
  if command -v cargo >/dev/null; then
    return
  fi
  if [ -f "$CARGOENV" ]; then
    info "sourcing cargo environment script"
    . "$HOME/.cargo/env"
    return
  fi
  error "unable to find cargo user directory. cargo must be added to \$PATH"
}

install_rust () {
  # skip if rustup is already installed
  if rustup --version >/dev/null 2>&1; then
    info "rust-lang is installed"
    return
  fi
  # install rust via curl script
  info "running rustup installer script"
  curl -sSf https://sh.rustup.rs | sh
  echo "\n"
  # source cargo environment
  export_cargo
}

update_rust () {
  info "updating rust binaries"
  rustup update
}

install_util () {
  binary=$1
  package=${2:-"$binary"}
  update=$3
  # skip install if not update-mode and binary already exists
  if [ -z "$update" ] && $binary --version >/dev/null 2>&1; then
    info "rust tool '$package' already installed."
    return
  fi
  # update/install tool otherwise
  info "installing rust tool '$package'"
  cargo install "$package"
}

#** Init **#

case "$1" in
  "install")
    install_rust
    ;;
  "update")
    export_cargo
    update_rust
    ;;
  "install-utils")
    export_cargo
    install_util rg ripgrep "$2"
    install_util fd fd-find "$2"
    install_util du du-dust "$2"
    ;;
  *)
    error "invalid command. use <install/update/install-utils>"
    ;;
esac
