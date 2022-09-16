#!/bin/sh

#
# Firejail utilities and patches
#

ISLIB=1 . "$(dirname $0)/push.sh"

#** Functions **#

#: desc => patch existing discord instance to use firejail config
patch_discord () {
  ensure_program discord
  # push firejail config to user profile
  log_info  "installing discord profile to $USER's config"
  copy_home ".config/firejail/discord.profile"
  # push patched desktop launcher to applications folder
  log_info "installing patched discord desktop application (as root)"
  SUDO=1 copy_root "/usr/share/applications/discord.desktop"
}

#** Init **#

ensure_program firejail

case "$1" in
  "discord") patch_discord ;;
  *)
    log_error "invalid command. try <discord/...>"
    exit 1
    ;;
esac
