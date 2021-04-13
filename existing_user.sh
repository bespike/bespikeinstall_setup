#!/usr/bin/env bash

cd /bespikeinstall/install
clear

# Get logged in user name
if [ $SUDO_USER ]; then
  RealUser=$SUDO_USER
else
  RealUser=$(whoami)
fi
echo -e "Modifying existing user $RealUser."
usermod -aG sudo $RealUser
echo '#It needs passwordless sudo functionality.
'""''"$RealUser"''""' ALL=(ALL) NOPASSWD:ALL
' | sudo -E tee /etc/sudoers.d/$RealUser >/dev/null 2>&1
echo '
cd /bespikeinstall/install
bash start.sh
' | sudo -E tee /usr/bin/bespikeinstall >/dev/null 2>&1
chmod +x /usr/bin/bespikeinstall

# Check required files and set global variables
#source pre_setup.sh

# Create the STORAGE_USER and STORAGE_ROOT directory if they don't already exist.
if ! id -u $STORAGE_USER >/dev/null 2>&1; then
  useradd -m $STORAGE_USER
fi
if [ ! -d $STORAGE_ROOT ]; then
  mkdir -p $STORAGE_ROOT
fi

# Save the global options in /etc/bespikeinstall.conf so that standlone
# tools know where to look for data.
#echo 'STORAGE_USER='"${STORAGE_USER}"'
#STORAGE_ROOT='"${STORAGE_ROOT}"'
#PUBLIC_IP='"${PUBLIC_IP}"'
#PUBLIC_IPV6='"${PUBLIC_IPV6}"'
#DISTRO='"${DISTRO}"'
#FIRST_TIME_SETUP='"${FIRST_TIME_SETUP}"'
#PRIVATE_IP='"${PRIVATE_IP}"'' | sudo -E tee /etc/bespikeinstall.conf >/dev/null 2>&1
echo 'STORAGE_USER='"${STORAGE_USER}"'
STORAGE_ROOT='"${STORAGE_ROOT}"'
DISTRO='"${DISTRO}"'
FIRST_TIME_SETUP='"${FIRST_TIME_SETUP}"'' | sudo -E tee /etc/bespikeinstall.conf >/dev/null 2>&1

cd ~
setfacl -m u:$RealUser:rwx /bespikeinstall
clear

echo -e "Your User has been modified . . ."
echo -e "$RED You must reboot the system for the new permissions to update and type$COL_RESET $GREEN bespikeinstall$COL_RESET $RED to continue setup . . .$COL_RESET"
exit 0