
# ensure programs exist on any unhandled error
$ErrorActionPreference = "Stop"

#** Variables **#

#: dotfiles directory
$DOTFILES = "$PSScriptRoot\..\dotfiles"

#: patches directory
$PATCHES = "$PSScriptRoot\..\patches"

#** Functions **#

function global:Which {
  param([string]$command)
  if (-NOT($command)) { throw "ERROR: Please supply a command name" }
  (Get-Command $command -ErrorAction SilentlyContinue).Path
}

function global:Ensure-Pkg {
  param([string]$bin, [string]$program)
  $program=if ("$program" -eq "") { $bin } else { $program }
  if (-NOT (Which $bin)) {
    Write-Host "[ERROR]: program missing: $program"
    exit 5
  }
}

function global:Scoop-Get {
  param([string]$bin, [string]$program)
  $program=if ("$program" -eq "") { $bin } else { $program }
  echo "bin=$bin"
  $null = scoop which $bin
  if ($?) {
    echo "[INFO]: upgrading $program w/ scoop"
    scoop update $program
  } else {
    echo "[INFO]: installing $program w/ scoop"
    scoop install $program
  }
}

function global:Confirm {
  param([string]$prompt)
  $confirmation = Read-Host "$prompt [y/n]"
  while($confirmation -ne "y")
  {
    if ($confirmation -eq "y") {
      return 1;
    }
    if ($confirmation -eq "n") {
      return 0;
    }
    $confirmation = Read-Host "$prompt [y/n]"
  }
}

# shamelessly stolen from:
# https://stackoverflow.com/questions/69236623/adding-path-permanently-to-windows-using-powershell-doesnt-appear-to-work/69239861#69239861
function Add-Path {
  param(
    [Parameter(Mandatory, Position=0)]
    [string] $LiteralPath,
    [ValidateSet('User', 'CurrentUser', 'Machine', 'LocalMachine')]
    [string] $Scope 
  )

  Set-StrictMode -Version 1; $ErrorActionPreference = 'Stop'

  $isMachineLevel = $Scope -in 'Machine', 'LocalMachine'
  if ($isMachineLevel -and -not $($ErrorActionPreference = 'Continue'; net session 2>$null)) { throw "You must run AS ADMIN to update the machine-level Path environment variable." }  

  $regPath = 'registry::' + ('HKEY_CURRENT_USER\Environment', 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment')[$isMachineLevel]

  # Note the use of the .GetValue() method to ensure that the *unexpanded* value is returned.
  $currDirs = (Get-Item -LiteralPath $regPath).GetValue('Path', '', 'DoNotExpandEnvironmentNames') -split ';' -ne ''

  if ($LiteralPath -in $currDirs) {
    Write-Verbose "Already present in the persistent $(('user', 'machine')[$isMachineLevel])-level Path: $LiteralPath"
    return
  }

  $newValue = ($currDirs + $LiteralPath) -join ';'

  # Update the registry.
  Set-ItemProperty -Type ExpandString -LiteralPath $regPath Path $newValue

  # Broadcast WM_SETTINGCHANGE to get the Windows shell to reload the
  # updated environment, via a dummy [Environment]::SetEnvironmentVariable() operation.
  $dummyName = [guid]::NewGuid().ToString()
  [Environment]::SetEnvironmentVariable($dummyName, 'foo', 'User')
  [Environment]::SetEnvironmentVariable($dummyName, [NullString]::value, 'User')

  # Finally, also update the current session's `$env:Path` definition.
  # Note: For simplicity, we always append to the in-process *composite* value,
  #        even though for a -Scope Machine update this isn't strictly the same.
  $env:Path = ($env:Path -replace ';$') + ';' + $LiteralPath

  Write-Verbose "`"$LiteralPath`" successfully appended to the persistent $(('user', 'machine')[$isMachineLevel])-level Path and also the current-process value."
}

#** Init **#

# ensure required programs are installed
Ensure-Pkg "scoop"
Ensure-Pkg "git"
