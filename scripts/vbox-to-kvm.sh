#!/bin/sh

LOGLEVEL='2'

. "$(dirname $0)/../install/_common.sh"

#** Variables **#

#: output for images
FPATH="/var/lib/libvirt/images"

#: cache for listing all vm-names
ALL_VMS=""

#: cache for listing qemu os-types
VIRT_OSTYPES=""

#** Functions **#

#: desc  => retrieve vm-name from hdd-uuid
#: usage => $hd-uuid
get_name() {
  # retrieve list of vms one time
  if [ -z "$ALL_VMS" ]; then
    ALL_VMS=`vboxmanage list vms`
  fi
  # assocate w/ grep
  echo "$ALL_VMS" | grep "{$1}" | cut -d '"' -f2
}

#: desc  => retrieve vms associated w/ harddrive
#: usage => $hd-uuid
assoc_hds() {
  t=`vboxmanage showmediuminfo "$1" | grep -oE '\(UUID: .*\)' | sed 's/(UUID: //' | sed 's/)//'`
  echo $t
}

#: desc  => retreieve property from vm info
#: usage => $info-data $property-name
info_prop() {
  echo "$1" | grep "^$2=" | cut -d '=' -f2  | cut -d '"' -f2
}

#: desc  => attempt to match virtualbox os-type to qemu os-type
#: usage => $vbox-os-type
find_ostype() {
  # retrieve list of ostypes one time
  if [ -z "$VIRT_OSTYPES" ]; then
    VIRT_OSTYPES=`virt-install --osinfo list` 
  fi
  # normalize os-name (remove parens, spaces, and lowercase)
  ostype=`echo "$1" | sed 's/([^)]*)//g;s/  / /g' | tr -d ' ' | tr '[:upper:]' '[:lower:]'`
  # replace windows with win and 20XX with 2kXX
  ostype=`echo "$ostype" | sed 's/windows/win/g' | sed 's/win20/win2k/g'`
  # if not found, try without numbers
  search=`echo "$VIRT_OSTYPES" | grep -m 1 "$ostype" | cut -d ',' -f1`
  [ ! -z "$search" ] && echo "$search" && return 0
  ostype=`echo "$ostype" | sed 's/[0-9]*//g'`
  # if still not found, return 'generic'
  search=`echo "$VIRT_OSTYPES" | grep -o 1 "$ostype" | cut -d ',' -f1`
  [ ! -z "$search" ] && echo "$search" && return 0
  echo 'generic'
}

#: desc  => convert hd image to raw disk
#: usage => $input-path $output-path
convert_raw() {
  echo "vboxmanage clonemedium --format RAW '$1' '$2'"
}

#: desc  => convert raw disk image to qcow2 disk
#: usage => $input-path $output-path
convert_qcow2() {
  echo "qemu-img convert -p -f raw '$1' -O qcow2 '$2'"
}

#** Init **#

ensure_program "virt-manager"
ensure_program "qemu-img" "qemu-utils"
ensure_program "vboxmanage" "virtualbox"

echo "# make export folder"
echo "mkdir -p '$FPATH'\n"

hdds=`vboxmanage list hdds | grep -e 'UUID' -e 'Parent UUID' -e 'Location' | nl -s '>'`
for i in `seq 1 3 $(echo "$hdds" | wc -l)`; do
  # ensure disk is parent image
  parent=`echo "$hdds" | grep " $(expr $i + 1)>" | awk '{print $3}'`
  if [ "$parent" != "base" ]; then
    continue;
  fi
  # retrieve uuid and location of disk
  uuid=`echo "$hdds" | grep " $i>" | awk '{print $2}'`
  location=`echo "$hdds" | grep " $(expr $i + 2)>" | cut -d ':' -f2 | xargs echo -n`
  # retrieve vms associated w/ hd-uuid
  vmlist=$(assoc_hds "$uuid")
  if [ -z "$vmlist" ]; then
    continue;
  fi
  # retrieve name/group for each vm associated w/ hd
  for vm in "$vmlist"; do
    # retrieve vm information
    name=$(get_name $vm)
    info=`vboxmanage showvminfo "$name" --machinereadable`
    os=`info_prop "$info" 'ostype'`
    cpus=`info_prop "$info" 'cpus'`
    ram=`info_prop "$info" 'memory'`
    match=`find_ostype "$os"`
    # generate qemu valid vm-name (no spaces, lowercase, snake-case)
    vmname=`echo "$name" | tr ' ' '_' | tr '_' '-' | sed 's/\([A-Z]\{1,\}\)/-\L\1/g;s/^-//'`
    vmname=`echo "$vmname" | tr -s '-' | tr '[:upper:]' '[:lower:]'`
    # generate filepaths for hd transition
    raw="/tmp/$name.raw"
    qcow2="/tmp/$vmname.qcow2"
    final="$FPATH/$vmname.qcow2"
    # convert disk to raw image format
    echo "echo 'export \"$name\" to qcow2'"
    convert_raw "$location" "$raw"
    # convert to qemnu format afterwards
    convert_qcow2 "$raw" "$qcow2"
    echo "rm -f '$raw'"
    echo "sudo mv '$qcow2' '$final'"
    echo "sudo chown root:root '$final'"
    # auto-import into virt-manager
    echo "echo 'importing \"$name\" into virt-manager'"
    echo "sudo virt-install --name '$vmname' --memory $ram --vcpus $cpus --disk $final,bus=sata --import --os-variant '$match' --network default --noreboot"
    echo ""
  done
done
