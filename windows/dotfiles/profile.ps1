

#** Functions **#

function global:Which {
  param([string]$command)
  if (-NOT($command)) { throw "ERROR: Please supply a command name" }
  (Get-Command $command -ErrorAction SilentlyContinue).Path
}

#** Init **#

if (Which eza.exe) { Set-Alias ls  -Value eza.exe -Option AllScope; }
if (Which bat.exe) { Set-Alias cat -Value bat.exe -Option AllScope; }

Set-PSReadLineKeyHandler -Chord Ctrl-a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Chord Ctrl-e -Function EndOfLine
Set-PSReadlineKeyHandler -Key ctrl+u -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine();
}

Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
