#
# Install and Configure Komorobi w/ Powershell for Windows
#

# load common utilies
. "$PSScriptRoot\_common.ps1"

#** Variables **#

#: configuration dir for komorobi and whkdrc
$CONFIG_DIR="$Env:USERPROFILE\.config"

#: whkd config source
$WHKD_CONFIG="$WIN_DOTFILES\config\whkdrc"

#: komorebi config source
$KOMOREBI_CONFIG="$WIN_DOTFILES\config\komorebi.json"

#: default.json configuration for powertoys KeyboardManager
$KEYBOARD_CONFIG="$WIN_DOTFILES\programs\powertoys\keyboard-manager.json"

#: filepath to PowerToys KeyBoardManager active configuration
$KEYBOARD_DEFAULT="$Env:USERPROFILE\AppData\Local\Microsoft\PowerToys\Keyboard Manager\default.json"

#: filepath to PowerToys KeyBoardManager executable
$KEYBOARD_BIN="C:\Program Files\PowerToys\KeyboardManagerEngine\PowerToys.KeyboardManagerEngine.exe"

#** Init **#

# ensure sudo package is instaled
Write-Host '[INFO]: installing sudo tool'
Scoop-Get sudo

# ensure longpath is enabled
Write-Host '[INFO]: enabling longpaths on windows'
sudo Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

# install dependencies
Write-Host '[INFO]: installing komorebi and dependencies'
$null = scoop bucket add extras
Scoop-Get whkd
Scoop-Get komorebi
Scoop-Get powertoys

# configure wkhdrc
Write-Host "[INFO]: configuring whkdrc in $CONFIG_DIR"
Copy-Item -Path "$WHKD_CONFIG" -Destination "$CONFIG_DIR\whkdrc" -Force

# configure komorebi
Write-Host "[INFO]: configuring komorebi in $CONFIG_DIR"
mkdir "$CONFIG_DIR" -ea 0
komorebic fetch-app-specific-configuration
Copy-Item -Path "$KOMOREBI_CONFIG" -Destination "$CONFIG_DIR\komorebi.json" -Force 
Move-Item -Path "$Env:USERPROFILE\applications.yaml" -Destination "$CONFIG_DIR\komorebi_applications.yaml" -Force 

# uninstall xbox-game-overlay
Write-Host "[INFO]: uninstalling xbox-game-overlay to recover hotkeys"
$null = Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage

# installing keyboard configurations for PowerToys KeyBoardManager
Write-Host "[INFO]: writing keyboard-manager configuration"
$null = taskkill /F /IM PowerToys.KeyboardManagerEngine.exe
Copy-Item -Path "$KEYBOARD_CONFIG" -Destination "$KEYBOARD_DEFAULT" -Force
Start-Process -FilePath "$KEYBOARD_BIN"
