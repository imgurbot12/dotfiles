#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables **#

#: repo configuration folder
NEOVIM="$CONFIG/neovim"

#: neovim system configuration location(s)
NCONFIG="$HOME/.config/nvim"
NBACKUP="$HOME/.config/nvim.backup"

#: astronvim repo and custom config directory
ASTRONVIM="https://github.com/AstroNvim/AstroNvim"
ASTROCONFIG="$NCONFIG/lua/user"

#** Functions **#

backup_config () {
  if [ ! -d "$NCONFIG" ]; then exit 0; fi
  if [ -d "$NBACKUP" ]; then
    warn "neovim backup folder '$NBACKUP' already exists"
    confirm_yes "delete existing backup (y/n)?"
    remove -rf "$NBACKUP"
  fi
  info "backing up existing neovim configurations"
  move -f "$NCONFIG" "$NBACKUP"
}

download_astronvim () {
  info "cloning astronvim to '$NCONFIG'"
  git clone "$ASTRONVIM" "$NCONFIG"
}

install_configs () {
  info "copying custom configurations into neovim"
  makedir -p $ASTROCONFIG || true
  copy "$NEOVIM/init.lua" "$ASTROCONFIG"
}

sync_neovim () {
  info "syncing neovim packages"
  nvim -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

#** Init **#

check_program nvim neovim

case "$1" in
  "install")
    backup_config
    download_astronvim
    install_configs
    sync_neovim
    ;;
  "update")
    install_configs
    sync_neovim
    ;;
  *)
    error "invalid command. use <install/update>"
    ;;
esac
