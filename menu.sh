#!/usr/bin/env bash

cd /bespikeinstall/install
source functions.sh


RESULT=$(dialog --stdout --nocancel --default-item 1 --title "Bespike Server Installer v0.01" --menu "Choose one" -1 60 16 \
' ' "- Daemon Wallet Builder -" \
1 "Daemonbuilder" \
9 Exit)

if [ $result = ]
then
  bash $(basename $0) && exit;
fi

if [ $result = 1 ]
then
  clear;
  cd $HOME/bespikeinstall/install
  source bootstrap_coin.sh;
fi

if [ $result = 9 ]
then
  clear;
  exit;
fi