#!/bin/sh

# stop program on any unhandled error
set -e

# import common-lib
. "$(dirname $0)/_common.sh"

# package versions
WL_ROOTS_VER="0.16.2"
WL_PROTO_VER="1.31"
WL_SERVER_VER="1.22.0"
LIBINPUT_VER="1.22-branch"
SWAYFX_VER="0.3.2"

# package sources
WL_ROOTS_GIT="https://gitlab.freedesktop.org/wlroots/wlroots.git"
WL_PROTO_GIT="https://gitlab.freedesktop.org/wayland/wayland-protocols.git"
WL_SERVER_GIT="https://gitlab.freedesktop.org/wayland/wayland.git"
LIBINPUT_GIT="https://gitlab.freedesktop.org/libinput/libinput.git"
SWAYFX_GIT="https://github.com/WillPower3309/swayfx.git"

BUILD_DIR="/tmp/sway-build"
INSTALLER=$(has_binary nala && echo "nala" || echo "apt")

#** Init **#

log_info "installing standard sway"
sudo $INSTALLER update
sudo $INSTALLER install sway

log_info "installing wayland build dependencies"
sudo $INSTALLER install -y \
  build-essential \
  cmake \
  meson \
  ninja-build \
  cmake-extras \
  gettext-base \
  fontconfig \
  libfontconfig-dev \
  libffi-dev \
  libxml2-dev \
  libdrm-dev \
  libxkbcommon-x11-dev \
  libxkbregistry-dev \
  libxkbcommon-dev \
  libpixman-1-dev \
  libudev-dev \
  libseat-dev \
  seatd \
  libxcb-dri3-dev \
  libvulkan-dev \
  libvulkan-volk-dev \
  vulkan-validationlayers-dev \
  libvkfft-dev \
  libgulkan-dev \
  libegl-dev \
  libgles2 \
  libegl1-mesa-dev \
  glslang-tools \
  libinput-bin \
  libinput-dev \
  libxcb-composite0-dev \
  libavutil-dev \
  libavcodec-dev \
  libavformat-dev \
  libxcb-ewmh2 \
  libxcb-ewmh-dev \
  libxcb-present-dev \
  libxcb-icccm4-dev \
  libxcb-render-util0-dev \
  libxcb-res0-dev \
  libxcb-xinput-dev \
  xdg-desktop-portal-wlr \
  hwdata

log_info "installing wlroots build dependencies"
sudo $INSTALLER install -y \
  wayland-protocols \
  libwayland-dev \
  libegl1-mesa-dev \
  libgles2-mesa-dev \
  libdrm-dev \
  libgbm-dev \
  libinput-dev \
  libxkbcommon-dev \
  libgudev-1.0-dev \
  libpixman-1-dev \
  libsystemd-dev \
  cmake \
  libpng-dev \
  libavutil-dev \
  libavcodec-dev \
  libavformat-dev \
  ninja-build \
  meson \
  xwayland \
  libgtk-3-dev

log_info "installing libinput dependencies"
sudo $INSTALLER install -y \
  edid-decode \
  check

log_info "installing sway build dependencies"
sudo $INSTALLER install -y \
  libjson-c-dev \
  libpango1.0-dev \
  libcairo2-dev \
  libgdk-pixbuf2.0-dev \
  scdoc

log_info "configuring build-dir"
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# download wayland-server
log_info "downloading wayland $WL_SERVER_VER"
[ ! -d "wayland" ] && git clone $WL_SERVER_GIT --branch $WL_SERVER_VER

log_info "downloading wayland-protocols"
[ ! -d "wayland-protocols" ] && git clone $WL_PROTO_GIT --branch $WL_PROTO_VER

# download wlroots
log_info "downloading wlroots $WL_ROOTS_VER"
[ ! -d "wlroots" ] && git clone $WL_ROOTS_GIT --branch $WL_ROOTS_VER

log_info "downloading libinput $LIBINPUT_VER"
[ ! -d "libinput" ] && git clone $LIBINPUT_GIT --branch $LIBINPUT_VER

log_info "downloading swayfx $SWAYFX_VER"
[ ! -d "swayfx" ] && git clone $SWAYFX_GIT --branch $SWAYFX_VER

# build wayland-server
log_info "building wayland"
cd wayland
meson build --prefix=/usr --buildtype=release -Ddocumentation=false 
ninja -C build
sudo ninja -C build install
cd ..

log_info "building wayland-protocols"
cd wayland-protocols
meson build --prefix=/usr --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..

# build wlroots
log_info "building wlroots $WL_ROOTS_VER"
cd wlroots
meson build --prefix=/usr --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..

# build libinput
log_info "building libinput $LIBINPUT_VER"
cd libinput
# sudo ln -s /usr/include/locale.h /usr/include/xlocale.h
sudo meson setup --prefix=/usr -Ddocumentation=false build
sudo ninja -C build
sudo ninja -C build install
cd ..

log_info "building swayfx $SWAYFX_VER"
cd swayfx
meson build
sudo ninja -C build
sudo ninja -C build install
cd ..

log_info "build complete!"
