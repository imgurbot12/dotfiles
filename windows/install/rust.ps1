#
# Install Rust via Scoop
#

. "$PSScriptRoot\_common.ps1"

#** Variables **#

$BINSTALL = "https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.ps1"

$CARGO_BIN = "$env:USERPROFILE\.cargo\bin"

#** Init **#

# ensure rust is installed
Scoop-Get rustup

# ensure cargo bin included in path
echo "[INFO]: adding '$CARGO_BIN' to PATH"
Add-Path "$CARGO_BIN" -Scope "User"

# ensure cargo binstall is installed
$null = cargo binstall --help
if (-NOT($?)) {
  echo "[INFO]: installing cargo-binstall feature"
  iex (iwr "$BINSTALL").Content
}
