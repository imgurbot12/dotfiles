#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables ***#

#: discord download link
DOWNLOAD="https://discord.com/api/download?platform=linux&format=deb"

FILE="$HOME/Downloads/discord.deb"

#** Init **#

# remove previous discord deb (if found)
rm -f $FILE

log_info "downloading latest deb package"
curl -sL $DOWNLOAD -o $FILE

log_info "installing discord deb package"
sudo dpkg -i $FILE

log_info "running firejail patches"
. "$(dirname $0)/firejail.sh"
