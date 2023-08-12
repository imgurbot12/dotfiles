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

#: neovim package manager plugin
NVIM_PACKER="https://github.com/wbthomason/packer.nvim"
NVIM_PACKER_INSTALL="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

#: astronvim repo and custom config directory
ASTRONVIM="https://github.com/AstroNvim/AstroNvim"

#: custom init file to install in astronvim folder
INIT_FILE="nvim/lua/user/init.lua"

#** Init **#

# download and install neovim otherwise
if ! has_binary nvim; then
  log_info "downloading neovim appimage to '$dest' (as root)"
  sudo curl -L "$NVIM_BINARY" -o $BIN
  sudo chmod +x $BIN
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
  copy_config $INIT_FILE
fi

# sync packer packages
log_info "syncing 'AstroNvim' packages"
nvim -c 'autocmd User PackerComplete quitall' -c 'PackerSync' || true

# notify on complete installation
log_info "installation complete"
