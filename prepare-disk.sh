#!/usr/bin/env bash
set -e

DISK=${DISK:-/dev/sda}
BOOTSIZE=${BOOTSIZE:-$((100*2**20))}
ROOTSIZE=${ROOTSIZE:-$((7*2**30))}
MEMSIZE=`free -b | awk '/Mem/{print $2}'`
SWAPSIZE=${SWAPSIZE:-$MEMSIZE}

echo -n "This will erase your disk [$DISK]. Are you sure you want to continue? (y/[n]): "
read reply
case "$reply" in
    Y|y|Yes|yes) ;;
    *) exit 0;;
esac

sgdisk --clear -g $DISK
partprobe $DISK

SECTORSIZE=512
FIRST=`sgdisk --first-aligned-in-largest $DISK`
LAST=`sgdisk --end-of-largest $DISK`

BOOTSTART=$FIRST
ROOTSTART=$((BOOTSTART + BOOTSIZE / SECTORSIZE))
BOOTLAST=$((ROOTSTART - 1))
HOMESTART=$((ROOTSTART + ROOTSIZE / SECTORSIZE))
ROOTLAST=$((HOMESTART - 1))
SWAPSTART=$((LAST - SWAPSIZE / SECTORSIZE))
HOMELAST=$((SWAPSTART - 1))
SWAPLAST=$LAST
GRUBMBR=34:$((FIRST - 1))

echo Partition table
echo "boot: $BOOTSTART:$BOOTLAST [$((BOOTSIZE / 2**20))MiB]"
echo "root: $ROOTSTART:$ROOTLAST [$((ROOTSIZE / 2**30))GiB]"
echo "home: $HOMESTART:$HOMELAST [$(((HOMELAST + 1 - HOMESTART) * 512 / 2**30))GiB]"
echo "swap: $SWAPSTART:$SWAPLAST [$((SWAPSIZE / 2**20))MiB]"
echo grub: $GRUBMBR

echo -n "Do you agree with proposed partition table? (y/[n]): "
read reply
case "$reply" in
    Y|y|Yes|yes) echo "You choose 'Yes'";;
    *) echo "You choose 'No'" && exit 0;;
esac

sgdisk --new 1:$BOOTSTART:$BOOTLAST --change-name 1:"Boot" --typecode 1:8300 \
    --new 2:$ROOTSTART:$ROOTLAST --change-name 2:"Root" --typecode 2:8300 \
    --new 3:$HOMESTART:$HOMELAST --change-name 3:"Home" --typecode 3:8300 \
    --new 4:$SWAPSTART:$SWAPLAST --change-name 4:"Swap" --typecode 4:8200 \
    --new 5:$GRUBMBR --change-name 5:"BIOS boot" --typecode 5:ef02 \
    $DISK

sgdisk -p $DISK

echo "Creating silesystems..."

mkfs.ext4 -L boot ${DISK}1
mkfs.ext4 -L root ${DISK}2
mkfs.ext4 -L home ${DISK}3
mkswap -L swap ${DISK}4

echo "Mounting..."

mount -L root /mnt
mkdir -p /mnt/{boot,home,shared}
mount -L boot /mnt/boot
mount -L home /mnt/home
swapon -L swap

echo DONE
