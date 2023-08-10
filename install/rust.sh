#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Variables **#

#: online script resource to install rustup
RUSTUP="https://sh.rustup.rs"

#: cargo environment source
CARGOENV="$HOME/.cargo/env"

#: cargo binstall utility install-script
BINSTALL="https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh"

#** Init **#

# ensure bash is installed
ensure_program bash

# source cargo env if available
if [ -f "$CARGOENV" ]; then
  log_debug "sourcing cargo environment"
  . "$CARGOENV"
fi

# skip if rust is already installed
if has_binary rustup; then
  log_info "rust-lang is already installed. updating installation..."
  rustup update
else
  # install rust via curl script
  log_info "running rustup installer script at '$RUSTUP'"
  curl -sSf $RUSTUP | bash
fi

# install cargo binstall utility
if ! cargo binstall --help >/dev/null 2>&1; then
  log_info "installing cargo-binstall feature"
  curl -sSf $BINSTALL | bash
else
  log_info "cargo-binstall found."
fi

