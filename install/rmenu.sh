#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Variables **#

#: rmenu git source
RMENU="https://github.com/imgurbot12/rmenu.git"

#: preferred css theme
RTHEME="themes/dark.css"

#: rmenu configuration location
RCONFIG="$HOME/.config/rmenu"

#** Init **#

# ensure rust and make are installed
ensure_program make
ensure_program cargo rust

# check if already installed
if has_binary rmenu && ! echo "$@" | grep -q '\-\-reinstall'; then
  log_warn "RMenu already installed. To Reinstall Include '--reinstall'"
  return 0
fi

# clone repo and move into directory
log_info "cloning source repository"
rm -rf /tmp/rmenu-install
git clone $RMENU /tmp/rmenu-install
cd /tmp/rmenu-install

# build project and install components
log_info "building project and installing binaries"
make all

# install theme from available themes
log_info "installing theme: $RTHEME"
cp -vf "/tmp/rmenu-install/$RTHEME" "$RCONFIG/style.css"

# delete host repo
log_info "deleting git-repo after successful install"
rm -rf /tmp/rmenu-install
