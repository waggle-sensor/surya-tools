#!/bin/bash -e

VERSION="1.0.4"

function cleanup()
{
  echo
  echo "<< Press <ENTER> to exit >>"
  read
}

trap cleanup EXIT

# make sure this script is executed as root
if [ "$EUID" -ne 0 ]
  then echo "ERROR (nx-prepare:01) Please run as root"
  exit
fi

FLASH="/home/waggle/Desktop/surya/images/nx/mfi_waggle_photon/nvmflash.sh"
KEY="/home/waggle/.ssh/ecdsa-surya-sage-waggle"
NODE="ws-nxcore-prereg.lan"
TTY="/dev/ttyUSB0"

print_help() {
  echo """
usage: nx_prepare.sh [-f <nvmflash.sh path>] [-k <ssh key>] [-n <ip address>]

Version: {$VERSION}

Flash a NX and shutdown after registration.

  -f : (optional) path to the Waggle flash script [default: ${FLASH}]
  -k : (optional) path to SSH key to communicate with the NX node during the process [default: ${KEY}]]
  -n : (optional) NX Node IP address [default: ${NODE}]
  -t : (optional) NX Serial TTY [default: ${TTY}]
  -? : print this help menu
"""
}

while getopts "f:k:n:t:?" opt; do
  case $opt in
    f) FLASH=$(realpath $OPTARG)
      ;;
    k) KEY=$(realpath $OPTARG)
      ;;
    n) NODE=$OPTARG
      ;;
    t) TTY=$OPTARG
      ;;
    ?|*)
      print_help
      exit 1
      ;;
  esac
done

echo "-------------------------"
echo "NX Flashing Recipe [${VERSION}]:"
echo -e " Flash:\t\t${FLASH}"
echo -e " SSH Key:\t${KEY}"
echo -e " NX IP:\t\t${NODE}"
echo -e " NX TTY:\t${TTY}"
echo "-------------------------"

if [ ! -f "${FLASH}" ]; then
  echo "ERROR (nx-prepare:02): unable to locate flash file [${FLASH}]"
  exit 1
fi

if [ ! -f "${KEY}" ]; then
  echo "ERROR (nx-prepare:03): unable to locate SSH key file [${KEY}]"
  exit 1
fi

if [ ! -c "${TTY}" ]; then
  echo "ERROR (nx-prepare:04): unable to locate TTY device [${TTY}]"
  exit 1
fi

echo "-- (1/5) ----------------"
echo "Enter System VSN"
echo "-------------------------"

ENTRY1=
ENTRY2=
while true; do
  echo
  read -p $'Enter VSN:\t' ENTRY1
  read -p $'Re-enter VSN:\t' ENTRY2
  if [ -z "$ENTRY1" ]; then
    echo "ERROR (nx-prepare:05): Input VSN must NOT be empty. TRY AGAIN"
    continue
  fi
  if [ "$ENTRY1" != "$ENTRY2" ]; then
    echo "ERROR (nx-prepare:06): Input VSN does NOT match. TRY AGAIN"
  else
    break
  fi
done
echo "Accepted VSN [$ENTRY1]"
echo

./_helper_scripts/nx/nx_flash.sh ${FLASH}
echo "-- (2/5) ----------------"
echo "NX Flashing COMPLETE!"
echo "-------------------------"

sleep 3s

./_helper_scripts/nx/nx_online.sh ${KEY} ${NODE}
echo "-- (3/5) ----------------"
echo "NX registration COMPLETE!"
echo "-------------------------"

sleep 3s

./_helper_scripts/nx/nx_vsn.sh ${KEY} ${NODE} ${ENTRY1}
echo "-- (4/5) ----------------"
echo "NX VSN Program COMPLETE!"
echo "-------------------------"

sleep 3s

./_helper_scripts/nx/nx_halt.sh ${KEY} ${NODE} ${TTY}
echo "-- (5/5) ----------------"
echo "NX shutdown COMPLETE."
echo " You may remove power."
echo "-------------------------"
