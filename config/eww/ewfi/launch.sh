
#** Variables **#

#: eww executable
EWW="$HOME/.cargo/bin/eww"

DIR="$(dirname $0)"

#** Init **#

"$DIR/scripts/cache.sh"

echo "EWFI: launching window"
$EWW open window_ewfi

"$DIR/scripts/search.sh"

