
#** Variables **#

set -x EDITOR nvim

# basic path installations
set -x GOROOT     "/usr/local/go"
set -x GOPATH     "$HOME/Code/golang"
set -x CARGO_PATH "$HOME/.cargo"
set -x PONY_PATH  "$HOME/.local/share/ponyup"
set -x MISE_PATH  "$HOME/.local/share/mise"

# omf installs
set -x NVM_PATH   "$HOME/.nvm"
set -x PYENV_PATH "$HOME/.pyenv"

# neovide config
set -x NEOVIDE_MULTIGRID true

#** Functions **#

function add_path -a bin path -d "verbose `fish_add_path` for specific binaries"
  if echo "$fish_user_paths" | grep -q "$path"; return 1; end
  echo "binary `$bin` adding `$path` to \$fish_user_path"
  fish_add_path "$path"
end

function ensure_path -a bin path -d "ensure the given binary/paths are in scope"
  if command -sq "$bin";  return 0; end
  if not test -d "$path"; return 1; end
  add_path $bin $path
  for path in $argv[3..-1]
    if test -d "$path"
      add_path $bin $path
    end
  end
end

function ensure_omf -a bin path -d "ensure the given omf program is installed"
  if not type -q omf;     return 1; end
  if not test -d "$path"; return 1; end
  if type -q "$bin";      return 0; end

  echo "installing binary `$bin` via OMF (detected at `$path`)"
  omf install "$bin"
end

function cmd_alias -a alias cmd args -d "generate a unique command alias"
  if not command -sq "$cmd"; return 1; end
  alias "$alias"="$cmd $args"
end

#** Init **#

# custom keybinds
# function fish_user_key_bindings
#     bind \cl 'clear -x && echo "ayy lmao"'
# end

# bultin paths
ensure_path "<builtin>" "$HOME/bin"
ensure_path "<builtin>" "$HOME/.local/bin"

# omf => nvm / pyenv
# ensure_omf "nvm"   "$NVM_PATH"
# ensure_omf "pyenv" "$PYENV_PATH"

# path => golang / rust (cargo) / pony / pyenv
ensure_path "go"    "$GOPATH/bin"     "$GOROOT/bin"
ensure_path "cargo" "$CARGO_PATH/bin"
ensure_path "ponyc" "$PONY_PATH/bin"
ensure_path "mise"  "$MISE_PATH/bin"
# ensure_path "pyenv" "$PYENV_PATH/bin"

# command aliases
cmd_alias vi   "nvim"
cmd_alias vim  "nvim"
cmd_alias code "neovide"
cmd_alias ls   "exa"
cmd_alias ll   "exa" "-l"
cmd_alias la   "exa" "-la"
cmd_alias cat  "bat"
cmd_alias find "fd"
cmd_alis  rtx  "mise"

# clipboard aliases
cmd_alias pbcopy  "wl-copy"
cmd_alias pbcopy  "xsel"  "-ib"
cmd_alias pbcopy  "xclip" "-selection c"
cmd_alias pbcopy  "wl-copy"
cmd_alias pbpaste "xsel"  "-ob"
cmd_alias pbpaste "xclip" "-selection c -o"
cmd_alias pbpaste "wl-paste"

# interactive startup
if status is-interactive
  if command -sq neofetch; neofetch; end
  if command -sq starship; eval (starship init fish); end
  if command -sq mise;     mise activate -s fish | source; end
  if command -sq zoxide;   zoxide init fish --cmd cd | source; end
end
