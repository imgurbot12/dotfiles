#!/bin/sh

. "$(dirname $0)/_common.sh"

#*** Variables **#

#: go download url
DOWNLOAD_URL="https://go.dev/dl/"

#** Functions **#

#: desc  => join url paths together
#: usage => $url $path
join_url() {
  if echo "$2" | grep -E 'https?://' 2>&1 >/dev/null; then
    echo "$2"
  elif echo "$2" | grep -E '^/' 2>&1 >/dev/null; then
    url=`echo "$1" | cut -d '/' -f-3`
    echo "$url$2"
  else
    url=`echo "$1" | cut -d '/' -f-3`
    pth=`echo "$1" | cut -d '/' -f4-`
    pth=`echo "$pth/$2" | sed 's|/\+|/|g'`
    echo "$url/$pth"
  fi
}

#** Init **#

log_info "scraping go.dev for latest version"
URL_PATH=$(
  curl -sL "$DOWNLOAD_URL" \
  | grep -m 1 'linux-amd64.tar.gz' \
  | grep -Eo 'href="[^\"]+"' \
  | cut -d '"' -f2)
GOURL=`join_url "$DOWNLOAD_URL" "$URL_PATH"`

log_info "downloading $GOURL"
mkdir -p /tmp/golang-build && cd /tmp/golang-build
curl -LC - "$GOURL" -o golang.tar.gz || true

log_info "installing $GOURL"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xvf golang.tar.gz

