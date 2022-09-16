#/bin/sh

#
# Push configuration files directly into their associated locations
#

. "$(dirname $0)/_common.sh"

#** Variables **#

#: configuration home folder for current user
CFG_HOME="$CONFIG/home/\$user"

#** Functions **#

#: usage => $cfg-base $real-base $path
_copy () {
  file=$(echo $3 | sed 's~^/~~')
  src="${1%%/}/$file"
  dest="${2%%/}/${file%%.}"
  dest_dir=$(dirname $dest)
  [ -d "$dest_dir" ] || file_mkdir "-p $dest_dir"
  file_copy "-rf '$src' '$dest'"
}

#: ex    => copy_root /usr/share/applications
#: usage => $path
copy_root () {
  _copy $CONFIG "/" "$1"
}

#: ex    => copy_home .config/firejail/
#: usage => $path
copy_home () {
  _copy $CFG_HOME $HOME "$1"
}

#: desc => push firejail configs to local config
push_firejail () {
  copy_home ".config/firejail/"
}

#: desc => push fish configs to local config
push_fish() {
  copy_home ".config/fish/config.fish" 
}

#: desc => push nvim configs to local config
push_nvim () {
  copy_home ".config/nvim/lua/user/init.lua"
}

#: desc => push all configs in `.config` to local home dir
push_dotconfig () {
  copy_home ".config/."
}

#: desc => push all configs related to xonsh
push_xonsh () {
  copy_home ".config/xonsh/."
  copy_home ".xonshrc"
}

#: desc => push all configs related to starship
push_starship () {
  copy_home ".local/bin/startheme.sh"
  copy_home ".config/starship/."
  chmod +x "$HOME/.local/bin/startheme.sh"
}

#: desc => push all configs for posix related shells
push_posix () {
  copy_home ".shellrc"
}

#: desc => push all desktop application definitions to root
push_desktop_apps () {
  copy_root "/usr/share/applications/."
}

#: desc => copy everything in the home folder config to real home 
push_home () {
  copy_home "/."
}

#: desc => push every root folder directly
push_root () {
  copy_root "/usr/."
}

#** Init **#

# skip init if being loaded as a library
[ -n "$ISLIB" ] && return 0

case "$1" in
  "home")         push_home         ;;
  "root")         push_root         ;;
  "config")       push_dotconfig    ;;
  "posixcfg")     push_posix        ;;
  "xonshcfg")     push_xonsh        ;;
  "fishcfg")      push_fish         ;;
  "starshipcfg")  push_starship     ;;
  "firejail")     push_firejail     ;;
  "desktop_apps") push_desktop_apps ;;
  *)
    log_error "invalid command. try <home/root/config/...>"
    exit 1
    ;;
esac
