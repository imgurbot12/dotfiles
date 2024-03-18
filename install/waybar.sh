#
# Manually Compile and Build the Latest Waybar
#

# stop program on any unhandled error
set -e

# import common-lib
. "$(dirname $0)/_common.sh"

#** Variables **#

#: api used to find waybar source
WAYBAR_SRC="https://api.github.com/repos/Alexays/Waybar/releases/latest"

#: waybar build directory
BUILD_DIR="/tmp/waybar"

#: location to download waybar tarball
BUILD_TAR="$BUILD_DIR/waybar-latest.tar.gz"

#: package installer
INSTALLER=$(has_binary nala && echo "nala" || echo "apt")

#** Functions **#

#: desc  => collect latest version of waybar from github
#: usage => download_source <force>
download_source() {
  force="$1"
  # get latest online version
  URL=$(
    curl -s $WAYBAR_SRC \
    | grep 'tarball_url' \
    | cut -d : -f 2,3 \
    | tr -d \", \
    | awk '{$1=$1; print $0}'
  )
  # compare installed version with online one
  latest=$(echo "$URL" | grep -Eo '[0-9]+.[0-9]+.[0-9]+')
  installed=$(get_version waybar)
  log_info "latest version: $latest"
  log_info "installed version: $installed"
  if [ -z "$force" ] && [ "$latest" = "$installed" ]; then
    log_info "already up to date. skipping install."
    exit 1
  fi
  # download latest version
  log_info "downloading waybar $latest source from github"
  mkdir -p "$BUILD_DIR"
  curl -L "$URL" -o "$BUILD_TAR"
}

#: desc => compile waybar from source and install
install_waybar() {
  # unzip latest version
  log_info "decompressing tarball"
  cd "$BUILD_DIR"
  tar xvf "$BUILD_TAR"
  # enter build directory and build
  log_info "configuring build via meson"
  cd */
  meson build --buildtype=release
  # compile project
  log_info "compiling build via ninja"
  ninja -C build
  # install project
  log_info "installing waybar via ninja"
  sudo ninja -C build install
}

#: desc => install dependencies for waybar
install_deps() {
  log_info "installing dependencies"
  sudo $INSTALLER install \
    clang-tidy \
    gobject-introspection \
    libdbusmenu-gtk3-dev \
    libevdev-dev \
    libfmt-dev \
    libgirepository1.0-dev \
    libgtk-3-dev \
    libgtkmm-3.0-dev \
    libinput-dev \
    libjsoncpp-dev \
    libmpdclient-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    libpulse-dev \
    libsigc++-2.0-dev \
    libspdlog-dev \
    libwayland-dev \
    scdoc \
    upower \
    libxkbregistry-dev \
    libiniparser-dev
  log_info "symlinking header files"
  sudo ln -s /usr/include/iniparser/iniparser.h /usr/include/. || true
  sudo ln -s /usr/include/iniparser/dictionary.h /usr/include/. || true
}

#** Init **#

#: ensure required programs
ensure_program meson
ensure_program ninja

install_deps
download_source
install_waybar
