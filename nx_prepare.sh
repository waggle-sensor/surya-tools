#!/bin/bash -e

VERSION="1.0.0"

# make sure this script is executed as root
if [ "$EUID" -ne 0 ]
  then echo "Error (nx-prepare:01) Please run as root"
  exit
fi

FLASH="/home/waggle/Desktop/surya/images/nx/mfi_waggle_photon/nvmflash.sh"
KEY="/home/waggle/.ssh/ecdsa-surya-sage-waggle"
NODE="ws-nxcore-prereg.lan"

print_help() {
  echo """
usage: nx_prepare.sh [-f <nvmflash.sh path>] [-k <ssh key>] [-n <ip address>]

Version: {$VERSION}

Flash a NX and shutdown after registration.

  -f : (optional) path to the Waggle flash script [default: ${FLASH}]
  -k : (optional) path to SSH key to communicate with the NX node during the process [default: ${KEY}]]
  -n : (optional) NX Node IP address [default: ${NODE}]
  -? : print this help menu
"""
}

while getopts "f:k:n:?" opt; do
  case $opt in
    f) FLASH=$(realpath $OPTARG)
      ;;
    k) KEY=$(realpath $OPTARG)
      ;;
    n) NODE=$OPTARG
      ;;
    ?|*)
      print_help
      exit 1
      ;;
  esac
done

if [ ! -f "${FLASH}" ]; then
  echo "Error (nx-prepare:02): unable to locate flash file [${FLASH}]"
  exit 1
fi

if [ ! -f "${KEY}" ]; then
  echo "Error (nx-prepare:03): unable to locate SSH key file [${KEY}]"
  exit 1
fi

echo "-------------------------"
echo "NX Flashing Recipe [${VERSION}]:"
echo -e " Flash:\t\t${FLASH}"
echo -e " SSH Key:\t${KEY}"
echo -e " NX IP:\t\t${NODE}"
echo "-------------------------"

./_helper_scripts/nx/nx_flash.sh ${FLASH}
echo "-- (1/3) ----------------"
echo "NX Flashing COMPLETE!"
echo "-------------------------"

sleep 3s

./_helper_scripts/nx/nx_online.sh ${KEY} ${NODE}
echo "-- (2/3) ----------------"
echo "NX registration COMPLETE!"
echo "-------------------------"

sleep 3s

./_helper_scripts/nx/nx_halt.sh ${KEY} ${NODE}
echo "-- (3/3) ----------------"
echo "NX shutdown COMPLETE."
echo " You may remove power."
echo "-------------------------"
