ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
RED=$ESC_SEQ"31;01m"
GREEN=$ESC_SEQ"32;01m"
YELLOW=$ESC_SEQ"33;01m"
BLUE=$ESC_SEQ"34;01m"
MAGENTA=$ESC_SEQ"35;01m"
CYAN=$ESC_SEQ"36;01m"

function spinner {
  local pid=$!
  local delay=0.75
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

function hide_output {
  OUTPUT=$(tempfile)
  $@ &> $OUTPUT & spinner
  E=$?
  if [ $E != 0 ]; then
    echo
    echo FAILED: $@
    echo -----------------------------------------
    cat $OUTPUT
    echo -----------------------------------------
    exit $E
  fi
  rm -f $OUTPUT
}

function apt_get_quiet {
  DEBIAN_FRONTEND=noninteractive hide_output sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" "$@"
}

function apt_install {
  PACKAGES=$@
  apt_get_quiet install $PACKAGES
}

function ufw_allow {
  if [ -z "$DISABLE_FIREWALL" ]; then
  sudo ufw allow $1 > /dev/null;
  fi
}

function restart_service {
	hide_output sudo service $1 restart
}

## Dialog Functions ##
function message_box {
	dialog --title "$1" --msgbox "$2" 0 0
}

function input_box {
  # input_box "title" "prompt" "defaultvalue" VARIABLE
  # The user's input will be stored in the variable VARIABLE.
  # The exit code from dialog will be stored in VARIABLE_EXITCODE.
  declare -n result=$4
  declare -n result_code=$4_EXITCODE
  result=$(dialog --stdout --title "$1" --inputbox "$2" 0 0 "$3")
  result_code=$?
}

function input_menu {
  # input_menu "title" "prompt" "tag item tag item" VARIABLE
  # The user's input will be stored in the variable VARIABLE.
  # The exit code from dialog will be stored in VARIABLE_EXITCODE.
  declare -n result=$4
  declare -n result_code=$4_EXITCODE
  local IFS=^$'\n'
  result=$(dialog --stdout --title "$1" --menu "$2" 0 0 0 $3)
  result_code=$?
}