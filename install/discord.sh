#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables ***#

#: discord download link
DOWNLOAD="https://discord.com/api/download?platform=linux&format=deb"

#: location to download discord into
FILE="/tmp/discord.deb"

#: magic discord build-file (used to update discord)
DISCORD_BUILD="/usr/share/discord/resources/build_info.json"

#: regex to parse version number
VERSION_REGEX="[0-9]+.[0-9]+.[0-9]+"

#** Functions **#

#: desc => simplify install by updating in place
update_discord() {
  # get current version
  log_info "discord already installed. checking version"
  current=$(cat "$DISCORD_BUILD" | grep 'version' | grep -oE "$VERSION_REGEX")
  log_info " - current version: '$current'"
  # check download version
  url=`curl "$DOWNLOAD" -s -L -I -o /dev/null -w '%{url_effective}'`
  latest=$(echo "$url" | grep -oE "$VERSION_REGEX" | head -n1)
  log_info " - latest version: '$latest'"
  # compare versions
  if [ "$current" = "$latest" ]; then
    log_info "discord already up to date. exiting"
    exit 0
  fi
  # update version in file
  log_info "inplace updating '$DISCORD_BUILD' to version '$latest'"
  sudo sed -i "s/$current/$latest/g" "$DISCORD_BUILD"
}

#: desc => manually install discord using latest deb
install_discord() {
  # remove previous discord deb (if found)
  rm -f $FILE
  # install discord
  log_info "downloading latest deb package"
  curl -sL $DOWNLOAD -o $FILE
  log_info "installing discord deb package"
  sudo dpkg -i $FILE
  # run firejail patch after install
  log_info "running firejail patches"
  . "$(dirname $0)/firejail.sh"
}

#** Init **#

# check if discord is already installed
if [ -f "$DISCORD_BUILD" ]; then
  update_discord
else
  install_discord
fi
