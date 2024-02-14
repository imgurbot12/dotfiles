#
# Configure and Setup Komorobi w/ Powershell for Windows
#
param([String]$command='start')

#** Variables **#

#: configuration dir for komorobi and whkdrc
$CONFIG_DIR="$Env:USERPROFILE\.config"

#: komorebi config source
$KOMOREBI_CONFIG="$CONFIG_DIR\komorebi.json"

#: filepath to PowerToys KeyBoardManager executable
$KEYBOARD_BIN="C:\Program Files\PowerToys\KeyboardManagerEngine\PowerToys.KeyboardManagerEngine.exe"

#** Functions **#

#: desc => stop komorebi process
function Stop-Komorebi ()
{
  Write-Host '[INFO]: killing existing komorebi/whkd instances'
  $null = komorebic stop
  $null = taskkill /F /IM yasb.exe
  $null = taskkill /F /IM whkd.exe
  $null = taskkill /F /IM whkd.exe
  $null = taskkill /F /IM komorebi.exe
  $null = taskkill /F /IM PowerToys.KeyboardManagerEngine.exe
}

#: desc => start komoroebi process
function Start-Komorebi ()
{
  # stop any current komorobi and whkd instances
  Stop-Komorebi 

  # ensure powertoys KeyboardManager is running
  Write-Host '[INFO]: starting keyboard-manager'
  $manager = Get-Process PowerToys.KeyBoardManagerEngine -ErrorAction 'SilentlyContinue'
  if (!$manager)
  {
    echo 'actually started it'
    Start-Process -FilePath "$KEYBOARD_BIN"
  }

  Write-Host '[INFO]: starting komorebi'
  komorebic start -c "$KOMOREBI_CONFIG" --whkd

  Write-Host '[INFO]: starting yasb status-bar'
  yasb
}

#** Init **#

switch ("$command")
{
  "stop"
  { Stop-Komorebi 
  }
  "start"
  { Start-Komorebi 
  }
  *
  { 
    Write-Host 'Invalid Command. Try <start/stop>.'
    exit 1
  }
}
