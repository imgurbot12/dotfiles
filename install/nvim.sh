#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Variables **#

#: binary install location
BIN="/usr/local/bin/nvim"

#: configuration folder for neovim
NVIM_CFG="$HOME/.config/nvim"

#: neovim downloadable appimage binary
NVIM_BINARY="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"

#** Init **#

# confirm if neovim should be updated/installed
install=1
if has_binary nvim; then
  install=0
  log_info "neovim already installed."
  confirm_yes 'update neovim? (y/n)' && install=1
fi

# download and install neovim otherwise
if [ $install -eq 1 ]; then
  log_info "downloading neovim appimage to '$BIN' (as root)"
  SUDO=1 file_remove "-rf $BIN"
  sudo curl -L "$NVIM_BINARY" -o $BIN
  sudo chmod +x $BIN
fi

# delete existing configuration if it exists
cfg="$HOME/.local/share/nvim/"
if [ -d "$NVIM_CFG" ]; then
  log_warn "neovim config folder already exists"
  if confirm_yes "delete existing config folder (y/n)?"; then
    file_remove "-rf $NVIM_CFG"
  fi
fi

# pushing latest config
if [ ! -d "$NVIM_CFG" ]; then
  log_info "pushing neovim config"
  copy_config "nvim/."
fi

# sync lazy packages
log_info "syncing 'lazy.nvim' packages"
nvim --headless "+Lazy! sync" +qa || true

# notify on complete installation
log_info "installation complete"
