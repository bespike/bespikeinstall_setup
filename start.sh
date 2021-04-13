#!/usr/bin/env bash
if [ $SUDO_USER ]; then
  RealUser=$SUDO_USER
else
  RealUser=$(whoami)
fi
echo $RealUser
echo $EUID
echo `id -u`