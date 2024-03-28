#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Variables **#

#: online script to install rtx multi-env language installer
MISE_INSTALL="https://mise.run"

#** Init **#

# ensure bash is installed
ensure_program bash

# check if binary already exists
if has_binary mise; then
  log_info "mise is already installed. updating installation..."
  mise self-update
  exit 0
fi

# install rtx as standard
curl -L $MISE_INSTALL | bash
