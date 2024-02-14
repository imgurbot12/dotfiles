#
# Install Yasb Status-Bar Tauri-Port
#

# load common utilies
. "$PSScriptRoot\_common.ps1"

#** Variables **#

#: link to tauri-prerequisites
$TAURI_PREREQS="https://tauri.app/v1/guides/getting-started/prerequisites"

#: yasb github repo
$YASB_GIT="https://github.com/isaacgale/yasb"

#: yasb rust branch
$YASB_BRANCH="tauri-port"

#: yasb release-build executable location
$YASB_BIN="src-tauri\target\release"

#: directory to export yasb binary into
$CARGO_BIN="$env:USERPROFILE\.cargo\bin"

#: yasb configuration direcctory
$YASB_CONFIG="$env:USERPROFILE\.config\yasb"

#** Init **#

# ensure required packages are installed
Ensure-Pkg cargo rust
Ensure-Pkg node nodejs

# warn about out-of-scope install requirements
Write-Host "[WARN]: Yasb Cannot Compiled w/o SDK Prerequisites"
Write-Host "   ... Please Verify Steps at ($TAURI_PREREQS)"

Write-Host "[INFO]: installing nerd-fonts"
$null = scoop bucket add nerd-fonts
Scoop-Get Hack-NF

# copy yasb config files onto host
Write-Host "[INFO]: copying config/css into $YASB_CONFIG"
$null = New-Item -ItemType Directory -Force -Path "$YASB_CONFIG"
Copy-Item "$WIN_DOTFILES\config\yasb\config.yaml" "$YASB_CONFIG\config.yaml" -Force
Copy-Item "$WIN_DOTFILES\config\yasb\styles.scss" "$YASB_CONFIG\styles.scss" -Force

# clone yasb tauri branch
Write-Host "[INFO]: cloning yasb (branch: $YASB_BRANCH)"
if (-NOT(Test-Path yasb))
{
  git clone $YASB_GIT --branch $YASB_BRANCH
}

# check if yasb executable already exists
Set-Location yasb
if (-NOT(Test-Path "$YASB_BIN"))
{
  Write-Host "[INFO]: installing node dependencies"
  npm install
  Write-Host "[INFO]: compiling tauri"
  npm run tauri build
} else
{
  Write-Host "[INFO]: executable already exists"
}

# copy binary to final destination
Write-Host "[INFO]: exporting binary to $CARGO_BIN\yasb.exe"
Copy-Item "$YASB_BIN\yasb.exe" "$CARGO_BIN\yasb.exe" -Force
Set-Location ..
