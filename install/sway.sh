#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#: api to get current public ip-address
IP_URL="ifconfig.me"

#: api get to get aproximate geo-location from ip
LOC_URL="https://ipinfo.io/"

#** Init **#

# ensure all required programs are installed
ensure_program sway      || export doexit=1
ensure_program swaylock  || export doexit=1
ensure_program waybar    || export doexit=1
ensure_program grim      || export doexit=1
ensure_program dunst     || export doexit=1
ensure_program redshift  || export doexit=1
ensure_program pactl     || export doexit=1
ensure_program playerctl || export doexit=1
[ ! -z "$doexit" ] && exit 1

# copy sway related shell script programs
log_info "installing binaries"
copy_bin "lock"
copy_bin "getmedia"

# copy configurations linked to sway config
log_info "installing configuration files"
copy_config "sway/."
copy_config "waybar/."
copy_config "dunst/."

# calcualte lattitude and longitude and generate config
log_info "calculating lattitude/longitude"
ip=`curl -s $IP_URL`
data=`curl -s "$LOC_URL/$ip"`
loc=`echo "$data" | awk -F '"' '/loc/ {print $4}'`
zone=`echo "$data" | awk -F '"' '/timezone/ {print $4}'`
lat=$(echo $loc | cut -d ',' -f1 | xargs printf "%.0f")
long=$(echo $loc | cut -d ',' -f2 | xargs printf "%.0f")

# generate redshift configuration w/ lattitude/longitude 
log_info "generating redshift config w/ tz='$zone' lat='$lat', long='$long'"
tee "$HOME/.config/redshift.conf" > /dev/null <<EOF
[redshift]
location-provider=manual

[manual]
lat=$lat
lon=$long
EOF
