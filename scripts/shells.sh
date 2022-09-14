#!/bin/sh

. "$(dirname $0)/_common.sh"

#** Variables **#

FISH_BIN="/usr/bin/fish"
FISH_CFG="$HOME/.config/fish/config.fish"

XONSH_PIP='xonsh[full]'
XONSH_SRC="$CONFIG/shell/xonshrc.py"
XONSH_CFG="$HOME/.xonshrc"

#NOTE: fixes https://github.com/prompt-toolkit/python-prompt-toolkit/issues/1241
XONSH_PROMPT="https://github.com/jnoortheen/python-prompt-toolkit.git"

ANYSHELL_SRC="$CONFIG/shell/anyshell.sh"
ANYSHELL_BIN="/usr/bin/anyshell"

#** Functions **#

alias exists="which >/dev/null 2>&1"

install_fish () {
  # let user install via package manager
  if ! fish --version >/dev/null 2>&1; then
    error "please install 'fish' via your package manager.\nExample: sudo apt install fish\n"
  fi
  # install configuration
  if [ ! -f $FISH_CFG ]; then
    info "installing fish configuration"
    copy "$CONFIG/shell/config.fish" "$FISH_CFG"
  fi
}

install_xonsh () {
  # ensure python and pip exists
  check_program pip3 python3-pip
  check_program python3
  # check to see if package is already installed
  if ! pip3 freeze | grep -q xonsh; then
    info "installing xonsh via pip"
    pip3 install $XONSH_PIP
    info "installing xonsh prompt hotfix"
    pip3 install git+${XONSH_PROMPT} -I
  fi
  # attempt to install .xonshrc
  if [ ! -f $XONSH_CFG ]; then
    info "installing xonsh config"
    copy "$XONSH_SRC" "$XONSH_CFG"
  fi
}

install_wrapper () {
  # install bin
  if [ ! -f $ANYSHELL_BIN ]; then
    info "installing anyshell wrapper"
    request_sudo "cp -vf '$ANYSHELL_SRC' '$ANYSHELL_BIN'"
  fi
  # install in /etc/shells
  if ! grep -q "$ANYSHELL_BIN" /etc/shells; then
    info "installing anyshell to /etc/shells"
    request_sudo "sh -c 'echo \"$ANYSHELL_BIN\" >> /etc/shells'"
  fi
  info "anyshell wrapper installed."
}

#** Init **#

case "$1" in
  "fish")
    install_fish
    install_wrapper
    ;;
  "xonsh")
    install_xonsh
    install_wrapper
    ;;
  "push")
    exists fish  && copy "$CONFIG/shell/config.fish" "$FISH_CFG"
    exists xonsh && copy "$XONSH_SRC" "$XONSH_CFG"
    ;;
  *)
    error "invalid command. try <fish/xonsh/...>"
    ;;
esac

