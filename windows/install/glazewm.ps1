#
# GlazeWM Install Script
#

# load common utilies
. "$PSScriptRoot\_common.ps1"

#** Variables **#

#: configuration source for glzr tools
$GLZR_CONFIG="$WIN_DOTFILES\config\glzr"

#: destination for glzr tools
$CONFIG_DIR="$Env:USERPROFILE\.glzr"

#** Init **#

Write-Host "[INFO]: installing glaze-wm"
winget install glzr-io.glazewm

Write-Host "[INFO]: installing zebar"
winget install glzr-io.zebar

Write-Host "[INFO]: installing configuration files"
$null = New-Item -ItemType Directory -Force -Path $CONFIG_DIR
Copy-Item -Path "$GLZR_CONFIG/*" -Destination "$CONFIG_DIR\." -Force -Recurse

