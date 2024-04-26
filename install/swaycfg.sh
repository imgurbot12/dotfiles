#!/bin/sh

# import common-lib
. "$(dirname $0)/_common.sh"

#: api to get current public ip-address
IP_URL="ifconfig.me"

#: api get to get aproximate geo-location from ip
LOC_URL="https://ipinfo.io/"

#: preferred installer program
INSTALLER=$(has_binary nala && echo "nala" || echo "apt")

#** Init **#

# ensure misc packages
ensure_program alacritty

# ensure all required programs are installed
log_info "installing required packages"
sudo $INSTALLER update
sudo $INSTALLER install -y \
  sway \
  swaybg \
  swaylock \
  swayidle \
  waybar \
  grim \
  slurp \
  dunst \
  redshift \
  pulseaudio-utils \
  playerctl \
  ncal

# copy sway related shell script programs
log_info "installing binaries"
copy_bin "lock"
copy_bin "mediactl"
copy_bin "waybarctl"
copy_bin "waybar-clock"
copy_bin "waybar-updates"

# copy configurations linked to sway config
log_info "installing configuration files"
copy_config "sway/."
copy_config "waybar/."
copy_config "dunst/."
copy_config "alacritty/."
copy_config "libinput-gestures.conf"

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
brightness=0.7

[manual]
lat=$lat
lon=$long
EOF
