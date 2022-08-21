
#** Variables **#

# basic path installations
set -x GOROOT     "/usr/local/go"
set -x GOPATH     "$HOME/Desktop/code/golang"
set -x CARGO_PATH "$HOME/.cargo"
set -x PONY_PATH  "$HOME/.local/share/ponyup"

# omf installs
set -x NVM_PATH "$HOME/.nvm"

#** Functions **#

function add_path -a bin path -d "verbose `fish_add_path` for specific binaries"
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
  if not type -q omf;     return 0; end
  if not test -d "$path"; return 0; end
  if type -q "$bin";      return 0; end

  echo "installing binary `$bin` via OMF (detected at `$path`)"
  omf install "$bin"
end

#** Init **#

# golang / rust (cargo) / pony
ensure_path "go"    "$GOROOT/bin"     "$GOPATH/bin"
ensure_path "cargo" "$CARGO_PATH/bin"
ensure_path "ponyc" "$PONY_PATH/bin"

# omf => nvm
ensure_omf "nvm" "$NVM_PATH"

# interactive startup
if status is-interactive
  neofetch
end
