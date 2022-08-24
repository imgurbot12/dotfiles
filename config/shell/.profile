# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

#: desc  => pretty export w/ allowed spacing
#: usage => var $variable $value
var () {
    export "$1"="$2"
}

#** Variables **#

var DESKTOP    "$HOME/Desktop"
var DOCUMENTS  "$HOME/Documents"

var GOROOT     "/usr/local/go"
var GOPATH     "$DESKTOP/code/golang"
var CARGO_PATH "$HOME/.cargo"
var PONY_PATH  "$HOME/.local/share/ponyup"
var PYENV_PATH "$HOME/.pyenv"
var NVM_PATH   "$HOME/.nvm"

#** Functions **#

#: desc  => return 1 if the given command does not exist
#: usage => ifc $binary
ifc () {
    type "$1" >/dev/null 2>&1 || return 1
    return 0
}

#: desc  => return 0 if given path exists but binary is not found
#: usage => is_missing $binary $path 
is_missing () {
    [ $# -lt 2 ]  && return 1
    ifc $1        || return 1
    [ ! -d "$2" ] && return 1
}

#: desc  => add the given path to bash-user-path variable 
#: usage => add_path $binary $path
add_path () {
    [ $# -ne 2 ] && return 1
    echo "$PATH" | grep -q "$2" && return 1
    echo "binary '$1' adding '$2' to \$PATH"
    export PATH="$2:$PATH"
}

#: desc  => add given paths to bash-user-path var if binary and paths exist
#: usage => ensure_path $binary $path
ensure_path () {
    is_missing $@ && return 1
    add_path $1 $2
    for path in "${@:2}"; do
        add_path $1 $path
    done
}

#: desc  => alias command only if specified command exists
#: usage => cmd_alias $alias $cmd $arguments
cmd_alias () {
    ifc "$2" || return 1
    alias "$1"="$2 $3"
}

#** Init **#

# source .bashrc if running bash & .bashrc exists
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi

# builtin paths
add_path "<builtin>" "$HOME/bin"
add_path "<builtin>" "$HOME/.local/bin"

# path => golang / rust (cargo) / pony / pyenv
ensure_path "go"    "$GOROOT/bin"     "$GOPATH/bin"
ensure_path "cargo" "$CARGO_PATH/bin"
ensure_path "ponyc" "$PONY_PATH/bin"
ensure_path "pyenv" "$PYENV_PATH/bin"

# init => pyenv / nvm
ifc "pyenv" && eval "$(pyenv init -)" 
is_missing "nvm" "$NVM_PATH" || . "$NVM_PATH/nvm.sh"

# command aliases
cmd_alias vi   "nvim"
cmd_alias vim  "nvim"
cmd_alias code "neovide"
cmd_alias ls   "exa"
cmd_alias ll   "exa" "-l"
cmd_alias la   "exa" "-la"
cmd_alias cat  "bat"
cmd_alias find "fd"

# clipboard aliases
cmd_alias pbcopy  "xsel"  "-ib"
cmd_alias pbcopy  "xclip" "-selection c"
cmd_alias pbpaste "xsel"  "-ob"
cmd_alias pbpaste "xclip" "-selection c -o"

# interactive startup
if [ ! -z "$PS1" ]; then
   ifc "neofetch" && neofetch
fi
