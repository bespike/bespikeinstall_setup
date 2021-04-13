#!/usr/bin/env bash

cd /bespikeinstall/install
source functions.sh
clear

# Root warning message box
message_box "Bespike Server Installer" \
"Naughty, naughty! You are trying to install this as the root user!
\n\nRunning any application as root is a serious security risk.
\n\nTherefore we make you create a user account :)"

# Ask if SSH key or password user
dialog --title "Create New User With SSH Key" \
--yesno "Do you want to create your new user with SSH key login?
Selecting no will create user with password login only." 7 60
response=$?
case $response in
   0) UsingSSH=yes;;
   1) UsingSSH=no;;
   255) echo "[ESC] key pressed.";;
esac

clear
if [ -z "${bespikeadmin:-}" ]; then
  DEFAULT_bespikeadmin=bespikeadmin
  input_box "New Account Name" \
  "Please enter your desired user name.
  \n\nUser Name:" \
  ${DEFAULT_bespikeadmin} \
  bespikeadmin
  if [ -z "${bespikeadmin}" ]; then
    exit
  fi
fi

clear
# If using SSH key login
if [[ ("$UsingSSH" == "yes") ]]; then
  if [ -z "${ssh_key:-}" ]; then
    DEFAULT_ssh_key=PublicKey
    input_box "Please open PuTTY Key Generator on your local machine and generate a new public key." \
    "To paste your Public key use ctrl shift right click.
    \n\nPublic Key:" \
    ${DEFAULT_ssh_key} \
    ssh_key
    if [ -z "${ssh_key}" ]; then
      exit
    fi
  fi
  
  # Create random user password
  RootPassword=$(openssl rand -base64 8 | tr -d "=+/")
  clear
  
  # Add user
  echo -e "Adding new user and setting SSH key . . . $COL_RESET"
  adduser ${bespikeadmin} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
  echo -e "${RootPassword}\n${RootPassword}" | passwd ${bespikeadmin}
  
  # Create SSH key structure
  mkdir -p /home/${bespikeadmin}/.ssh
  touch /home/${bespikeadmin}/.ssh/authorized_keys
  chown -R ${bespikeadmin}:${bespikeadmin} /home/${bespikeadmin}/.ssh
  chmod 700 /home/${bespikeadmin}/.ssh
  chmod 644 /home/${bespikeadmin}/.ssh/authorized_keys
  authkeys=/home/${bespikeadmin}/.ssh/authorized_keys
  echo "$ssh_key" > "authkeys"
fi
if [[ ("$UsingSSH" == "no") ]]; then
   # New User Password Login Creation
   if [ -z "${RootPassword:-}" ]; then
    DEFAULT_RootPassword=$(openssl rand -base64 8 | tr -d "=+/")
    input_box "User Password" \
    "Enter your new user password or use this randomly system generated one.
    \n\nUnfortunatley dialog doesnt let you copy. So you have to write it down.
    \n\nUser password:" \
    ${DEFAULT_RootPassword} \
    RootPassword
    if [ -z "${RootPassword}" ]; then
      # user hit ESC/cancel
      exit
    fi
  fi
  clear
  
  dialog --title "Verify Your Responses" \
  --yesno "Please verify your answers before you continue:
  
  New User Name : ${bespikeadmin}
  New User Pass : ${RootPassword}" 8 60
  
  # Get exit status
  # 0 means user hit [yes] button.
  # 1 means user hit [no] button.
  # 255 means user hit [Esc] key.
  response=$?
  case $response in
    0)
      clear
      echo -e "Adding new user and password . . .$COL_RESET"
      sudo adduser ${bespikeadmin} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
      echo -e ""${RootPassword}"\n"${RootPassword}"" | passwd ${bespikeadmin};;
    1)
      clear
      bash $(basename $0) && exit;;
    255) ;;
  esac
fi

usermod -aG sudo ${bespikeadmin}
echo '#It needs passwordless sudo functionality.
'""''"${bespikeadmin}"''""' ALL=(ALL) NOPASSWD:ALL
' | sudo -E tee /etc/sudoers.d/${bespikeadmin} >/dev/null 2>&1
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

if [[ ("$UsingSSH" == "yes") ]]; then
  echo "New User is installed make sure you saved your private key . . ."
fi

if [[ ("$UsingSSH" == "no") ]]; then
  echo "New User is installed . . ."
fi

echo -e "$RED Please reboot system and log in as the new user and type$COL_RESET $GREEN bespikeinstall$COL_RESET $RED to continue setup . . .$COL_RESET"
exit 0