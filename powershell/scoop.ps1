#
# Install Scoop w/ Script
#

# ensure execution-policy is confiugred properly
policy=(Get-ExecutionPolicy)
if ("$policy" -ne "RemoteSigned") {
  echo "[INFO]: Configuring Execution Policy"
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
}

# install scoop
echo "[INFO]: installing/upgrading scoop"
iwr -useb get.scoop.sh | iex

# install useful packages
echo "[INFO]: installing git w/ scoop"
scoop install git
