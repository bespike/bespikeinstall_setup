#!/usr/bin/env bash

cd /bespikeinstall/install
source functions.sh


RESULT=$(dialog --stdout --nocancel --default-item 1 --title "Bespike Server Installer v0.01" --menu "Choose one" -1 60 16 \
' ' "- Server Software -" \
1 "Install Docker" \
9 Exit)

if [ $RESULT = ]
then
  bash $(basename $0) && exit;
fi

if [ $RESULT = 1 ]
then
  clear;
  cd $HOME/bespikeinstall/install
  echo -e "Installing needed packages for docker . . .$COL_RESET"
  sudo apt-get -q -q update
  apt_get_quiet install apt-transport-https ca-certificates curl gnupg lsb-release || exit 1
  if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
    hide_output curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  fi
  if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  fi
  echo -e "Installing docker . . .$COL_RESET"
  sudo apt-get -q -q update
  apt_get_quiet install docker-ce docker-ce-cli containerd.io
  
  echo -e "Creating docker group . . .$COL_RESET"
  sudo groupadd docker
  
  echo -e "Adding $RealUser to the docker group . . .$COL_RESET"
  sudo usermod -aG docker $RealUser
  
  echo -e "Please relogin to use docker command$COL_RESET"
  echo -e "Docker has been installed"
fi

if [ $RESULT = 9 ]
then
  clear;
  exit;
fi