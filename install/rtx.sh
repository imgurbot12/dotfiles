#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Variables **#

#: online script to install rtx multi-env language installer
RTX="https://rtx.pub/install.sh"

#** Init **#

# ensure bash is installed  
ensure_program bash

# check if binary already exists
if has_binary rtx; then 
  log_info "rtx is already installed. updating installation..."
  rtx self-update
  exit 0
fi

# install rtx as standard
curl -L $RTX | bash
