#
# Install Various Shell Utilities
#

# load common utilies
. "$PSScriptRoot\_common.ps1"

#** Init **#

# ensure packages are installed
Ensure-Pkg cargo rust
$null = cargo binstall --help
if (-NOT($?))
{
  Write-Error "[ERROR]: cargo-binstall not found."
  exit 2
}

Write-Host "[INFO]: installing coreutils"
Win-Install uutils.coreutils coreutils

Write-Host "[INFO]: installing rust binaries"
cargo binstall bat -y
cargo binstall ripgrep -y
cargo binstall fd-find -y
cargo binstall du-dust -y
cargo binstall git-delta -y

