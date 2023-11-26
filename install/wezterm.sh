#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables **#

#: source for latest release files
RELEASES_URL="https://api.github.com/repos/wez/wezterm/releases/latest"

#** Init **#

# retrieve distro information
export_distro

# copy config before install
log_info "copying wezterm config"
copy_home ".wezterm.lua"

# base installation around distro and available release urls
log_info "searching wezterm releases"
urls=`curl -sL "$RELEASES_URL" | grep '"browser_download_url":' | cut -d'"' -f4`
case $(get_distro) in
  "ubuntu"|"debian")
    version=$(get_distro_version)
    url=`echo "$urls" | grep -E "${OS}${VER}.deb$"`
    if [ ! -z "$url"  ]; then
      log_info "installing from debian package"
      curl -L "$url" -o /tmp/wezterm.deb
      sudo dpkg -i /tmp/wezterm.deb
      exit 0
    fi
    ;;
esac

# build from source if sub-install option not found
log_info "distro not supported. installing from source"
ensure_program "cargo" "rust"

url=`echo "$urls" | grep -E '.tar.gz$'`
rel=$(echo "$url" \
  | grep -Eo 'wezterm-([0-9a-zA-Z]+-?)+' \
  | sed 's/^wezterm-//g; s/-src$//g')
[ -z "$rel" ] && log_error "unable to locate source" && exit 1

mkdir -p /tmp/wezterm-build && cd /tmp/wezterm-build
curl -L "$url" -o wezterm.tar.gz
tar xvf wezterm.tar.gz
cd "wezterm-$rel"

log_info "compiling sources"
cargo build --release

log_info "installing binaries"
SUDO=1 file_copy "-vf target/release/wezterm            /usr/bin/"
SUDO=1 file_copy "-vf target/release/wezterm-gui        /usr/bin/"
SUDO=1 file_copy "-vf target/release/wezterm-mux-server /usr/bin/"
SUDO=1 file_copy "-vf target/release/strip-ansi-escapes /usr/bin/"
