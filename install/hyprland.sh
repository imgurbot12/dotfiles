
set -e

. "$(dirname $0)/_common.sh"

#** Variables **#

BUILD_DIR="/tmp/hyprland-build"

WLPROTO_GIT="https://gitlab.freedesktop.org/wayland/wayland-protocols.git"
WLPROTO_VER="1.36"

HYPRLANG_GIT="https://github.com/hyprwm/hyprlang"
HYPRLANG_VER="v0.4.2"

HYPRCURSOR_GIT="https://github.com/hyprwm/hyprcursor.git"
HYPRCURSOR_VER="v0.1.7"

HYPRWAYLAND_GIT="https://github.com/hyprwm/hyprwayland-scanner"
HYPRWAYLAND_VER="v0.3.4"

HYPRLAND_GIT="https://github.com/hyprwm/Hyprland"
HYPRLAND_VER="v0.40.0"

#** Init **#

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Install Dependencies
log_info "installing dependencies"
sudo apt install -y \
  libzip-dev \
  librsvg2-dev \
  libtomlplusplus-dev \
  libpugixml-dev \
  libxcb-util-dev

# Clone Repos

log_info "cloning wayland-protocols $WLPROTO_VER"
git clone "$WLPROTO_GIT" wayland-protocols --branch "$WLPROTO_VER" || true

log_info "cloning hyprlang $HYPRLANG_VER"
git clone "$HYPRLANG_GIT" hyprlang --branch "$HYPRLANG_VER" || true

log_info "cloning hyprcusor $HYPRCURSOR_VER"
git clone "$HYPRCURSOR_GIT" hyprcursor --branch "$HYPRCURSOR_VER" || true

log_info "cloning hyprwayland-scanner $HYPRWAYLAND_GIT"
git clone "$HYPRWAYLAND_GIT" hyprwayland-scanner --branch "$HYPRWAYLAND_VER" || true

log_info "cloning hyprland $HYPRLAND_VER"
git clone --recursive "$HYPRLAND_GIT" hyprland --branch "$HYPRLAND_VER" || true

# Build Repos

log_info "installing wayland-protocols $WLPROTO_VER"
cd "$BUILD_DIR/wayland-protocols"
meson build --prefix=/usr --buildtype=release
ninja -C build
sudo ninja -C build install

log_info "installing hyprlang $HYPRLANG_VER"
cd "$BUILD_DIR/hyprlang"
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target hyprlang -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`

log_info "installing hyprcursor $HYPRCURSOR_VER"
cd "$BUILD_DIR/hyprcursor"
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
sudo cmake --install build

log_info "installing hyprwayland-scanner $HYPRWAYLAND_VER"
cd "$BUILD_DIR/hyprwayland-scanner"
cmake -DCMAKE_INSTALL_PREFIX=/usr -B build
cmake --build build -j `nproc`
sudo cmake --install build

log_info "installing hyprland $HYPRLAND_VER"
cd "$BUILD_DIR/hyprland"
make all
sudo make install
