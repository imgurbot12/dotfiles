#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables **#

#: repository for fastfetch
FASTFETCH_REPO="fastfetch-cli/fastfetch"

#** Functions **#

#: desc  => compare versions to confirm if install should happen
#: usage => "$package_url"
check_versions() {
  # check if url was found
  if [ -z "$1" ]; then
    log_error 'failed to find release'
    exit 1
  fi
  # compare versions
  current=`get_version fastfetch`
  latest=`get_github_version "$1"`
  log_info " - current version: $current"
  log_info " - latest version: $latest"
  if [ "$current" = "$latest" ]; then
    log_info "already up to date. skipping install."
    exit 0
  fi
}

#** Init **#

# install fastfetch
case "$(get_distro)" in
  "ubuntu"|"debian")
    log_info "debian-os detected. installing from .deb package"
    url=`get_github_deb "$FASTFETCH_REPO"`
    check_versions "$url"
    curl -L "$url" -o /tmp/fastfetch.deb
    sudo dpkg -i /tmp/fastfetch.deb
    ;;
  *)
    log_info "unknown distro '$DISTRO'. installing from source"
    ensure_program cmake
    url=`get_github_tarball "$FASTFETCH_REPO"`
    check_versions "$url"
    mkdir -p /tmp/fastfetch && cd /tmp/fastfetch
    curl -L "$url" -o fastfetch.tar.gz
    tar xvf fastfetch.tar.gz
    cd */
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
