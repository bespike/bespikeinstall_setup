#!/usr/bin/env bash
if [ $SUDO_USER ]; then
  RealUser=$SUDO_USER
else
  RealUser=$(whoami)
fi

cd /bespikeinstall/install

# Recall the last settings used if we're running this a second time.
if [ -f /etc/bespikeinstall.conf ]; then
  #load the old .conf file to get existing configuration options loaded
  cat /etc/bespikeinstall.conf | sed s/^/DEFAULT_/ > /tmp/bespikeinstall.prev.conf
  source /tmp/bespikeinstall.prev.conf
  rm -f /tmp/bespikeinstall.prev.conf
else
  FIRST_TIME_SETUP=1
fi

source functions.sh
# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files. This is also
# in the management daemon startup script and the cron script.
if ! locale -a | grep en_US.utf8 > /dev/null; then
  #ubuntu = hide_output locale-gen en_US.UTF-8
  sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
  hide_output locale-gen
fi
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
# /bespikeinstall/install/start.sh: line 40: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8): No such file or directory
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Fix so line drawing characters are shown correctly in Putty on Windows.
export NCURSES_NO_UTF8_ACS=1

if [[ ("$FIRST_TIME_SETUP" == "1") ]]; then
  clear
  chmod +x editconf.py
  
  # Check system setup:
  # If not, this shows an error and exits.
  source preflight.sh
  
  # Check for user
  echo -e "Installing needed packages for setup to continue . . .$COL_RESET"
  apt-get -q -q update
  apt_get_quiet install dialog python3 python3-pip acl nano apt-transport-https sudo || exit 1
  
  # Welcome
  message_box "Bespike Server Installer" \
  "Hello and thanks for using the Bespike Server Installer!
  \n\nInstallation for the most part is fully automated. In most cases any user responses that are needed are asked prior to the installation.
  \n\nNOTE: You should only install this on a brand new Debain 10 installation."
  if [ $SUDO_USER ]; then
    source existing_user.sh
    exit
  else
    source create_user.sh
    exit
  fi
  cd ~
else
  clear
  
  # Load our variables.
  source /etc/bespikeinstall.conf
  # Start menu
  source menu.sh
  echo
  echo "-----------------------------------------------"
  echo
	echo Thank you for using the Bespike Server Installer!
	echo
	echo To run this installer anytime simply type, bespikeinstall!
  cd ~
fi