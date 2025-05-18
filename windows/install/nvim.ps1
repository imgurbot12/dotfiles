#
# Install Neovim w/ Powershell for Windows
#

# load common utilies
. "$PSScriptRoot\_common.ps1"

#** Variables **#

$NVIM_CFG="$LINUX_DOTFILES\config\nvim"

$ASTRONVIM_URL="https://github.com/AstroNvim/AstroNvim"

$CONFIG="$env:LOCALAPPDATA\nvim"
$DATA="$env:LOCALAPPDATA\nvim-data"

#** Init **#

# ensure gcc is installed
Ensure-Pkg gcc

# install neovim
Win-Install Neovim.Neovim neovim

# backup existing neovim data
if (Test-Path $CONFIG) {
  if ((Confirm "Neovim Config Already Exists. Delete it?") -eq 1) {
    $null = Remove-Item -LiteralPath "$CONFIG" -Force -Recurse
    $null = Remove-Item -LiteralPath "$DATA" -Force -Recurse
  }
}

# clone astronvim into place if not already there
if (-NOT (Test-Path $CONFIG)) {
  # configure astronvim
  Write-Host "[INFO]: moving files to $CONFIG"
  git clone --depth 1 $ASTRONVIM_URL $CONFIG
  $null = Copy-Item "$NVIM_CFG\*" "$CONFIG\lua\." -Force
}

# ensure mason is updated
Write-Host "[INFO]: updating neovim packages"
nvim --headless "+Lazy! sync" +qa

# notify completion
Write-Host "[INFO]: installation complete"
