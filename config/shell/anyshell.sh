#!/bin/sh

SHELLS='
xonsh
fish
bash
zsh
'

#: usage => launch $bin
launch () {
  export SHELL="$1" && exec "$1"
}

for shell in $SHELLS; do
  bin=$(which $shell 2>/dev/null)
  [ -n "$bin" ] && echo "[*] launching $shell at '$bin'" && launch $bin
done

echo '[!] unable to find a valid shell. reverting to /bin/sh' >/dev/stderr
launch /bin/sh
