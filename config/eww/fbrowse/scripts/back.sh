#!/bin/sh

#
# List files one directory back from current browser path
#

EWW="$HOME/.cargo/bin/eww"

path=$($EWW get fbrowse_path)
echo "BROWSE: back from '$path'"
eval "$(dirname $0)/files.sh update-results $(dirname $path)"
