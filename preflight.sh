#!/usr/bin/env bash

if [ "`lsb_release -d | sed 's/.*:\s*//'`" == "Debian GNU/Linux 10 (buster)" ]; then
  DISTRO=debian_10
fi
if [ "`lsb_release -d | sed 's/.*:\s*//'`" == "Raspbian GNU/Linux 10 (buster)" ]; then
  DISTRO=raspbian_10
  if [ ! -d /vagrant ]; then
    mkdir /vagrant
  fi
fi
if [ ! $DISTRO ]; then
  echo "This os is not supported"
  echo "We currently only support Debian 10"
  exit
fi

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ]; then
  echo "Bespike Server Installer only supports x86_64 and will not work on any other architecture, like ARM or 32 bit OS."
  echo "Your architecture is $ARCHITECTURE"
  exit
fi

TOTAL_PHYSICAL_MEM=$(head -n 1 /proc/meminfo | awk '{print $2}')
if [ $TOTAL_PHYSICAL_MEM -lt 1436000 ]; then
  if [ ! -d /vagrant ]; then
    TOTAL_PHYSICAL_MEM=$(expr \( \( $TOTAL_PHYSICAL_MEM \* 1024 \) / 1000 \) / 1000)
    echo "Your Server needs more memory (RAM) to function properly."
    echo "Please provision a machine with at least 1536 GB, 6 GB recommended."
    echo "This machine has $TOTAL_PHYSICAL_MEM MB memory."
    exit
  fi
fi

if [ $TOTAL_PHYSICAL_MEM -lt 1436000 ]; then
  echo "WARNING: Your Server has less than 1.5 GB of memory."
  echo " It might run unreliably when under heavy load."
fi

# check swap
echo Checking if swap space is needed and if so creating . . .
SWAP_MOUNTED=$(cat /proc/swaps | tail -n+2)
SWAP_IN_FSTAB=$(grep "swap" /etc/fstab)
ROOT_IS_BTRFS=$(grep "\/ .*btrfs" /proc/mounts)
TOTAL_PHYSICAL_MEM=$(head -n 1 /proc/meminfo | awk '{print $2}')
AVAILABLE_DISK_SPACE=$(df / --output=avail | tail -n 1)
if
  [ -z "$SWAP_MOUNTED" ] &&
  [ -z "$SWAP_IN_FSTAB" ] &&
  [ ! -e /swapfile ] &&
  [ -z "$ROOT_IS_BTRFS" ] &&
  [ $TOTAL_PHYSICAL_MEM -lt 1536000 ] &&
  [ $AVAILABLE_DISK_SPACE -gt 5242880 ]
then
  echo "Adding a swap file to the system . . ."
  # Allocate and activate the swap file. Allocate in 1KB chuncks
  # doing it in one go, could fail on low memory systems
  fallocate -l 3G /swapfile
  if [ -e /swapfile ]; then
    chmod 600 /swapfile
    hide_output mkswap /swapfile
    swapon /swapfile
    echo "vm.swappiness=10" >> sudo /etc/sysctl.conf
  fi
  # Check if swap is mounted then activate on boot
  if swapon -s | grep -q "\/swapfile"; then
    echo "/swapfile  none swap sw 0  0" >> sudo /etc/fstab
  else
    echo "ERROR: Swap allocation failed"
  fi
fi

# Set STORAGE_USER and STORAGE_ROOT to default values (bespike-data and /home/bespike-data), unless
# we've already got those values from a previous run.
if [ -z "$STORAGE_USER" ]; then
  STORAGE_USER=$([[ -z "$DEFAULT_STORAGE_USER" ]] && echo "bespike-data" || echo "$DEFAULT_STORAGE_USER")
fi
if [ -z "$STORAGE_ROOT" ]; then
  STORAGE_ROOT=$([[ -z "$DEFAULT_STORAGE_ROOT" ]] && echo "/home/$STORAGE_USER" || echo "$DEFAULT_STORAGE_ROOT")
fi