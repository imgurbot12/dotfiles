#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Variables **#

#: applications to remove firecfg restrictions from
FREE="
vlc
obs
eog
gimp
wget
clamtk
clamscan
virtualbox
VirtualBox
steam
"

#** Init **#

ensure_program firejail

log_info "installing custom jails"
copy_config "firejail"

log_info "jailing common applications"
firecfg --fix
sudo firecfg

log_info "freeing safe/important programs"
for app in $FREE; do
  log_info " - freeing $app"
  SUDO=1 file_remove "-f /usr/local/bin/$app"
done

log_info "installing patches"
SUDO=1 file_copy "-f $PATCHES/discord.desktop /usr/share/applications/discord.desktop"

log_info "refreshing desktop environment"
xdg-desktop-menu forceupdate || true
