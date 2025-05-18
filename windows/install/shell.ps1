#
# Install Shell Helpers and Utilities
#

# load common utilies
. "$PSScriptRoot\_common.ps1"

Write-Host "[INFO]: installing powershell readline"
Install-Module PSReadLine -Repository PSGallery -Scope CurrentUser -Force

Write-Host "[INFO]: installing eza - better ls alternative"
winget install eza-community.eza

Write-Host "[INFO]: installing zoxide shell history"
winget install ajeetdsouza.zoxide

Write-Host "[INFO]: copying powershell profile"
Copy-Item "$WIN_DOTFILES\profile.ps1" $PROFILE -Force
