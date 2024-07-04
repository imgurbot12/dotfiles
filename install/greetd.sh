#!/bin/sh

set -e
. "$(dirname $0)/_common.sh"

#** Variables **#

#: project build directory
BUILD_DIR="/tmp/greetd"

#: github source for greetd
GREETD_GIT="https://git.sr.ht/~kennylevinsen/greetd"

#: greetd version to install
GREETD_VER="0.10.3"

#: github source for regreet
REGREET_GIT="https://github.com/rharish101/ReGreet.git"

#: regreet version to install
REGREET_VER="main"

#** Init **#

# ensure rust is installed to build programs
ensure_program cargo rust

# Install Dependencies
log_info "installing base greetd"
sudo apt update
sudo apt install -y greetd

log_info "shutting down greetd"
sudo systemctl stop greetd

# copy configuration files
SUDO=1 file_copy "-rf '$DOTFILES/etc/greetd' '/etc/'"
sudo chown -R root:root /etc/greetd/

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

log_info "cloning greetd"
git clone "$GREETD_GIT" greetd --branch "$GREETD_VER" || true

log_info "cloning regreet"
git clone "$REGREET_GIT" regreet --branch "$REGREET_VER"

log_info "compiling and upgrading greetd ($GREETD_VER)"
cd "$BUILD_DIR/greetd"
cargo build --release
SUDO=1 file_copy './target/release/greetd /usr/local/bin/greetd'

log_info "compiling and install regreet ($REGREET_VER)"
cd "$BUILD_DIR/regreet"
cargo build --release
SUDO=1 file_copy './target/release/regreet /usr/local/bin/regreet'

log_info "restarting greetd service"
sudo systemctl restart greetd
