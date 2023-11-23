#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables **#

#: fastfetch version to install
VERSION="2.2.3"

#: fastfetch source download link
FASTFETCH_RAW="https://github.com/fastfetch-cli/fastfetch/archive/refs/tags/$VERSION.tar.gz"

#: fastfetch deb download
FASTFETCH_DEB="https://github.com/fastfetch-cli/fastfetch/releases/download/2.2.3/fastfetch-$VERSION-Linux.deb"

#** Init **#

# install fastfetch
case "$(get_distro)" in
  "ubuntu"|"debian")
    log_info "debian-os detected. installing from .deb package"
    curl -L "$FASTFETCH_DEB" -o /tmp/fastfetch.deb
    sudo dpkg -i /tmp/fastfetch.deb
    ;;
  *)
    log_info "unknown distro '$DISTRO'. installing from source"
    ensure_program cmake
    mkdir -p /tmp/fastfetch && cd /tmp/fastfetch
    curl -L "$FASTFETCH_RAW" -o fastfetch.tar.gz
    tar xvf fastfetch.tar.gz
    cd "fastfetch-$VERSION"
    sh "./run.sh"
    sudo cp -vf ./build/fastfetch /usr/bin/.
    ;; 
esac

# copy fastfetch configuration
log_info "copying fastfetch config"
copy_config "fastfetch/."

# alias fastfetch to neofetch
if ! has_binary "neofetch"; then
  log_info "linking neofetch to fastfetch"
  sudo ln -s /usr/bin/fastfetch /usr/local/bin/neofetch
fi
