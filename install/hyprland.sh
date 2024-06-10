#!/bin/sh

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

HYPRIDLE_GIT="https://github.com/hyprwm/hypridle"
HYPRIDLE_VER="v0.1.2"

HY3_GIT="https://github.com/outfoxxed/hy3"
HY3_VER="0.40.0"

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
  libxcb-util-dev \
  libsdbus-c++-dev

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

log_info "cloning hypridle $HYPRIDLE_VER"
git clone "$HYPRIDLE_GIT" hypridle --branch "$HYPRIDLE_VER" || true

log_info "cloning hyprland plugin hy3 $HY3_VER"
git clone "$HY3_GIT" hy3 --branch "$HY3_VER" || true

# Build Hyprland

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

# Install Tools

log_info "installing hypridle $HYPRIDLE_VER"
cd "$BUILD_DIR/hypridle"
cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -S . -B ./build
cmake --build ./build --config Release --target hypridle -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
sudo cmake --install build

# Install Plugins

# commits from https://github.com/outfoxxed/hy3/pull/115
log_info "patching hy3 $HY3_VER with dmg-fix PR commits"
cd "$BUILD_DIR/hy3"
git cherry-pick 445381f
git cherry-pick 968cadf
git cherry-pick 11fcce5
git cherry-pick 3bf93f5
git cherry-pick 0cb9391

log_info "installing hy3 plugin $HY3_VER"
cmake -DCMAKE_BUILD_TYPE=Release -B build
cmake --build build
sudo cmake --install build
