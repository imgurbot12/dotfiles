#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables **#

CRUNCH_GIT="https://github.com/chrissimpkins/Crunch.git"
CRUNCH_VER="v5.0.0"

BUILD_DIR="/tmp/crunch"
INSTALL_DIR="/opt/crunch"

BIN_INSTALL="/usr/local/bin/crunch"
BIN_CONTENTS="#!/bin/sh
export HOME="$INSTALL_DIR"
exec python3 $INSTALL_DIR/crunch.py \$@"

#** Init **#

log_info "preparing build-dir: $BUILD_DIR"
mkdir -p $BUILD_DIR
cd "$BUILD_DIR"

log_info "preparing install-dir: $INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo chown -R $USER:$USER "$INSTALL_DIR"

log_info "cloning crunch $CRUNCH_VER"
git clone "$CRUNCH_GIT" crunch --branch "$CRUNCH_VER" || true

#NOTE: Crunch install tries to pout everything within the `$HOME`
# directory. So in order to install it somewhere else we have to
# trick the program into thinking that directory is `$HOME`.
# (yes this is very dumb, but the program is cool enough to cope)

log_info "overriding \$HOME variable for install"
HOME_BACKUP="$HOME"
export HOME="$INSTALL_DIR"

log_info "building crunch dependencies"
cd "$BUILD_DIR/crunch"
make build-dependencies

log_info "installing crunch binary"
cp src/crunch.py "$INSTALL_DIR/crunch.py"
echo "$BIN_CONTENTS" | sudo tee "$BIN_INSTALL"
sudo chmod +x "$BIN_INSTALL"

log_info "hardening install-dir: $INSTALL_DIR"
sudo chown -R root:root /opt/crunch
