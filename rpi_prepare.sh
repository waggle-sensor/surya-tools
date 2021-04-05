#!/bin/bash -e

VERSION="1.0.0"

# make sure this script is executed as root
if [ "$EUID" -ne 0 ]
  then echo "Error (rpi-prepare:01) Please run as root"
  exit
fi

FLASH="/home/waggle/Desktop/surya/images/rpi/rpi-pxe-setup.img"
KEY="/home/waggle/.ssh/ecdsa-surya-sage-waggle"
NODE="raspberrypi.lan"
SDDEV="/dev/sdc"

print_help() {
  echo """
usage: rpi_prepare.sh [-f <rpi-pxe-setup.img path>] [-k <ssh key>] [-n <ip address>] [-d <sd device>]

Version: {$VERSION}

Flash a NX and shutdown after registration.

  -f : (optional) path to the RPI flash image [default: ${FLASH}]
  -k : (optional) path to SSH key to communicate with the RPi during the process [default: ${KEY}]]
  -n : (optional) RPi Node IP address [default: ${NODE}]
  -d : (optional) SD card device path [default: ${SDDEV}]
  -? : print this help menu
"""
}

while getopts "f:k:n:d:?" opt; do
  case $opt in
    f) FLASH=$(realpath $OPTARG)
      ;;
    k) KEY=$(realpath $OPTARG)
      ;;
    n) NODE=$OPTARG
      ;;
    d) SDDEV=$OPTARG
      ;;
    ?|*)
      print_help
      exit 1
      ;;
  esac
done

if [ ! -f "${FLASH}" ]; then
  echo "Error (rpi-prepare:02): unable to locate flash file [${FLASH}]"
  exit 1
fi

if [ ! -f "${KEY}" ]; then
  echo "Error (rpi-prepare:03): unable to locate SSH key file [${KEY}]"
  exit 1
fi

if [ ! -b "${SDDEV}" ]; then
  echo "Error (rpi-prepare:04): unable to locate SD device [${SDDEV}]"
  exit 1
fi

echo "-------------------------"
echo "RPi Flashing Recipe [${VERSION}]:"
echo -e " Flash:\t\t${FLASH}"
echo -e " SSH Key:\t${KEY}"
echo -e " NX IP:\t\t${NODE}"
echo -e " SD Dev:\t${SDDEV}"
echo "-------------------------"

./_helper_scripts/rpi/rpi_burn.sh ${FLASH} ${SDDEV}
echo "-- (1/3) ----------------"
echo "RPi Flashing COMPLETE!"
echo "-------------------------"

echo
echo "Insert the SD card into the RPi, connect the RPi ethernet and power on RPi."
echo "  Press <ENTER> when done..."
read

./_helper_scripts/rpi/rpi_eeprom.sh ${KEY} ${NODE}
echo "-- (2/3) ----------------"
echo "RPi EEPROM Prep COMPLETE!"
echo "-------------------------"

sleep 3s

./_helper_scripts/rpi/rpi_halt.sh ${KEY} ${NODE}
echo "-- (3/3) ----------------"
echo "RPi shutdown COMPLETE."
echo " You may remove power."
echo "-------------------------"
