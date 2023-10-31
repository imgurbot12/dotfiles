#
# Instlal Neovim w/ Powershell for Windows
#

# load common utilies
. "$PSScriptRoot\_common.ps1"

#** Variables **#

$INIT_FILE="$DOTFILES\config\nvim\lua\user\init.lua"

$ASTRONVIM_URL="https://github.com/AstroNvim/AstroNvim"

$CONFIG="$env:LOCALAPPDATA\nvim"

#** Init **#

# install neovim
Scoop-Get nvim neovim

# backup existing neovim data
if (Test-Path $CONFIG) {
  if ((Confirm "Neovim Config Already Exists. Delete it?") -eq 1) {
    $null = Remove-Item -LiteralPath "$CONFIG" -Force -Recurse
  }
}

# clone astronvim into place if not already there
if (-NOT (Test-Path $CONFIG)) {
  # configure astronvim
  Write-Host "[INFO]: cloning AstroNvim to $CONFIG"
  git clone --depth 1 $ASTRONVIM_URL $CONFIG
  $null = New-Item -Path "$CONFIG\lua\user" -ItemType Directory
  # copy init file
  $null = Copy-Item "$INIT_FILE" "$CONFIG\lua\user\init.lua" -Force
}

# ensure mason is updated
Write-Host "[INFO]: updating neovim packages"
nvim +MasonUpdate +qall

# notify completion
Write-Host "[INFO]: installation complete"
