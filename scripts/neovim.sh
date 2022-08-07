#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables **#

#: neovim downloadable appimage binary
BINARY="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"

#: repo configuration folder
NEOVIM="$CONFIG/neovim"

#: neovim system configuration location(s)
NCONFIG="$HOME/.config/nvim"
NBACKUP="$HOME/.config/nvim.backup"

#: astronvim repo and custom config directory
ASTRONVIM="https://github.com/AstroNvim/AstroNvim"
ASTROCONFIG="$NCONFIG/lua/user"

#** Functions **#

install_neovim () {
  # skip if neovim is already installed
  if nvim --help >/dev/null 2>&1; then
    info "neovim binary installed"
    return
  fi
  # download and install neovim otherwise
  download="/tmp/nvim.appimage"
  info "downloading neovim appimage"
  if [ ! -f "$download" ]; then
    curl -L -o "$download" "$BINARY"
    chmod +x "$download"
  fi
  request_sudo "mv -vf $download /usr/local/bin/nvim"
}

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

case "$1" in
  "install")
    install_neovim
    check_program nvim neovim

    backup_config
    download_astronvim
    install_configs
    sync_neovim
    ;;
  "push")
    install_configs
    ;;
  "update")
    install_configs
    sync_neovim
    ;;
  *)
    error "invalid command. use <install/update/push>"
    ;;
esac
