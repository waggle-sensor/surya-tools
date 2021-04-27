#!/bin/bash

FLASH=${1:-""}
SDDEV=${2:-""}

if [ ! -f "${FLASH}" ]; then
  echo "ERROR (rpi-burn:01): unable to locate flash file [${FLASH}]"
  exit 1
fi

if [ ! -b "${SDDEV}" ]; then
  echo "ERROR (rpi-burn:02): unable to locate SD device [${SDDEV}]"
  exit 1
fi

# make sure this script is executed as root
if [ "$EUID" -ne 0 ]
  then echo "ERROR (rpi-burn:03) Please run as root"
  exit 1
fi

echo "Burning image [$FLASH] to SD card [$SDDEV]..."
dd if=${FLASH} of=${SDDEV} status=progress bs=4M
if [ $? -ne 0 ]; then
  echo "ERROR (rpi-flash:04): RPI SD burn failure"
  exit 1
fi
echo "Burning image finished"
echo " You may safely remove the SD card now."
