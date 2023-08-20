#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#** Variables **#

#: fonts directory
FONTSDIR="$HOME/.local/share/fonts"

#: nerdfonts used in starship
NERDFONTS="
https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/FiraCode.zip
"

#** Init **#

ensure_program unzip

# check if already installed
if [ -f "$FONTSDIR/readme.md" ] && ! echo "$@" | grep -q '\-\-reinstall'; then
  log_warn "NerdFonts already installed. To Reinstall Include '--reinstall'"
  return 0
fi

# ensure install-dir exists
file_mkdir "-p $FONTSDIR"
 
# install fonts into fonts-directory
dest="/tmp/nerdfonts.zip"
log_info "installing nerd fonts to '$FONTSDIR'"
for font in $NERDFONTS; do
  # download via curl
  log_info "- installing font: '$font'"
  curl -L "$font" -o $dest
  # unzip contents into fontsdir
  unzip -qod $FONTSDIR $dest
  file_remove $dest
done

# install fontconfig
log_info "installing custom font-config"
copy_config "fontconfig"

# update font-settings
log_info "updating font cache"
fc-cache -frv
