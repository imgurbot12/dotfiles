#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables **#

#: download link for neovide download
NEOVIDE="https://github.com/neovide/neovide/releases/latest/download/neovide.tar.gz"

#: neovide shell wrapper location
WRAPPER="/usr/local/bin/neovide"

#: installation destination folder
DESTINATION="/opt/neovide/"

#** Functions **#

get_neovide_version () {
  binary=${1:-"$DESTINATION/neovide"}
  version="$($binary --version 2>&1 | grep -oE '[0-9]\.([0-9]\.?)+')" || true
  echo "$version"
}

download_neovide () {
  # config
  bundle="/tmp/neovide.tar.gz"
  target="/tmp/neovide"
  binary="$target"
  # download binary
  info "downloading neovide binary"
  if [ ! -f "$bundle" ]; then
   curl -L -o $bundle $NEOVIDE
  fi
  # unpackage in tmp
  info "unpackaging tar bundle"
  if [ ! -f "$binary" ]; then
    /bin/sh -c "cd /tmp/ && tar xvf $bundle" >/dev/null 2>&1
  fi
  if [ ! -f "$binary" ]; then
    error "unable to locate neovide binary after unbundling"
  fi
  # compare downloaded version to existing version
  NEW_VERSION="$(get_neovide_version $binary)"
  if [ "$NEW_VERSION" = "$CURRENT_VERSION" ]; then
    warn "neovide already up to date. cancelling installation"
    remove -f "$target"
    return
  fi
  # request move of binary to /opt/
  info "moving download to final path"
  chmod +x $binary
  request_sudo "sh -c 'mkdir -p $DESTINATION && mv -vf $binary $DESTINATION && rm -vf $target'"
}

wrap_neovide () {
  info "installing neovide shell wrapper"
  if [ -f "$WRAPPER" ]; then
    warn "wrapper already installed"
    return
  fi
  request_sudo "cp -vf $CONFIG/neovide/neovide.sh $WRAPPER"
}

#** Init **#

#: track actively installed neovide version (if applicable)
CURRENT_VERSION=$(get_neovide_version)

case "$1" in
  "install")
    download_neovide
    wrap_neovide
    ;;
  *)
    echo "invalid command. use <install/...>"
    ;;
esac
