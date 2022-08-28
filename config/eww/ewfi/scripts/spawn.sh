#!/bin/sh

#** Variables **#

#: eww binary 
EWW="$HOME/.cargo/bin/eww"

#** Init **#

# spawn new process
echo "spawning command: '$@'"
nohup $@ &
disown

# close base window
echo "closing ewfi"
$EWW close window_ewfi
