#!/bin/sh

ISLIB=1 . "$(dirname $0)/push.sh"

#** Variables **#

#: binary install location
BIN="/usr/local/bin"

## Neovim variables

#: configuration folder for neovim
NVIM_CFG="$HOME/.config/nvim"

#: neovim downloadable appimage binary
NVIM_BINARY="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"

#: neovim package manager plugin
NVIM_PACKER="https://github.com/wbthomason/packer.nvim"
NVIM_PACKER_INSTALL="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

#: astronvim repo and custom config directory
ASTRONVIM="https://github.com/AstroNvim/AstroNvim"

## Neovide variables

#: download link for neovide download
NEOVIDE="https://github.com/neovide/neovide/releases/latest/download/neovide.tar.gz"

## Rust variables

#: online script resource to install rustup
RUSTUP="https://sh.rustup.rs"

#: cargo environment source
CARGOENV="$HOME/.cargo/env"

## Pyenv variables

#: online script resource to install pyenv
PYENV="https://pyenv.run"

## Golang variables

#: latest golang packaged release
GORELEASE="https://go.dev/dl/go1.19.1.linux-amd64.tar.gz"

## Starship variables

#: fonts directory
FONTSDIR="$HOME/.local/share/fonts"

#: nerdfonts used in starship
NERDFONTS="
https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip
"

#** Functions **#

_source_cargo () {
  if [ -f "$CARGOENV" ]; then
    log_debug "sourcing cargo environment"
    . "$CARGOENV"
  fi
}

install_nvim () {
  # download and install neovim otherwise
  if ! has_binary nvim; then
    dest="$BIN/nvim"
    log_info "downloading neovim appimage to '$dest' (as root)"
    sudo curl -L "$NVIM_BINARY" -o $dest
  fi
  # clone and install packer
  if [ ! -d "$NVIM_PACKER_INSTALL" ]; then
    log_info "cloning 'Packer' - Neovim Package Manager"
    git clone $NVIM_PACKER $NVIM_PACKER_INSTALL
  fi
  # delete existing configuration if it exists
  cfg="$HOME/.local/share/nvim/"
  if [ -d "$NVIM_CFG" ]; then
    log_warn "neovim config folder already exists"
    if confirm_yes "delete existing config folder (y/n)?"; then
      file_remove "-rf $NVIM_CFG"
    fi
  fi
  # clone and push latest astronvim config if allowed
  if [ ! -d "$NVIM_CFG" ]; then
    # clone and install astronvim as nvim config
    log_info "cloning 'AstroNvim' to '$NVIM_CFG'"
    git clone $ASTRONVIM $NVIM_CFG
    # installing custom user config into astronvim config
    log_info "pushing user config for 'AstroNvim'"
    push_nvim
  fi
  # sync packer packages
  log_info "syncing 'AstroNvim' packages"
  nvim -c 'autocmd User PackerComplete quitall' -c 'PackerSync' || true
  # notify on complete installation
  log_info "installation complete"
}

install_neovide () {
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
  dest="$BIN/neovide"
  log_info "moving neovide to '$dest' (as root)"
  SUDO=1 file_move "-f $target $dest"
}

install_rust () {
  # source cargo env if available
  _source_cargo
  # skip if rust is already installed
  if has_binary rustup; then
    log_info "rust-lang is already installed. updating installation..."
    rustup update; return 0
  fi
  # install rust via curl script
  log_info "running rustup installer script at '$RUSTUP'"
  curl -sSf $RUSTUP | sh
}

install_rust_utils () {
  # source cargo env if available
  _source_cargo
  # attempt to install various rust utilities
  ensure_program cargo rust
  install () {
    bin=$1
    pkg=${2:-"$bin"}
    update=$3
    if [ -z "$update" ] && has_binary $bin; then
      log_info "rust tool '$1' already installed" && return 0
    fi
    log_info "installing rust tool '$pkg'"
    cargo install "$pkg"
  }
  install rg  ripgrep "$1"
  install fd  fd-find "$1"
  install du  du-dust "$1"
  install exa exa     "$1"
  install bat bat     "$1"
}

install_pyenv () {
  ensure_program bash
  has_binary pyenv && log_info "pyenv is already installed." && return 0
  curl -L $PYENV | bash
}

install_golang () {
  has_binary go && log_info "golang is already installed." && return 0
  # download latest release
  target="/tmp/go-release.tar.gz"
  log_info "downloading go release from '$GORELEASE'"
  curl -L $GORELEASE -o $target
  # move release to final destination
  dest="/usr/local"
  log_info "installing go release (as root)"
  sudo sh -c "rm -rf /usr/local/go && tar -C $dest -xzf $target"
  file_remove "-f $target"
}

install_starship () {
  # source cargo and ensure rust is installed
  _source_cargo
  ensure_program cargo rust
  # install starship theming utility
  push_starship
  # install nerdfonts
  if [ ! -f "$FONTSDIR/readme.md" ]; then
    ensure_program unzip
    file_mkdir "-p $FONTSDIR"
    # install fonts into fonts-directory
    dest="/tmp/nerdfonts.zip"
    log_info "installing nerd fonts to '$FONTSDIR'"
    for font in $NERDFONTS; do
      # download via curl
      log_info "- installing font: '$font'"
      curl -L "$font" -o $dest
      # unzip contents into fontsdir
      unzip -qod $FONTSDIR $dest
      file_remove $dest
    done
  fi
  # install starship
  has_binary "starship" && log_info "starship is already installed" && return 0
  log_info "installing starship"
  cargo install starship
}

#** Init **#

case "$1" in
  "nvim")       install_nvim            ;;
  "neovide")    install_neovide         ;;
  "rust")       install_rust            ;;
  "rust-utils") install_rust_utils "$2" ;;
  "pyenv")      install_pyenv           ;;
  "golang")     install_golang          ;;
  "starship")   install_starship        ;;
  *)
    log_error "invalid command. try <nvim/neovide/rust/pyenv/...>"
    exit 1
    ;;
esac
