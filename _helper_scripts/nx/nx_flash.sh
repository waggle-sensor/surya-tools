#!/bin/bash

FLASH=${1:-""}

if [ ! -f "${FLASH}" ]; then
  echo "ERROR (nx-flash:01): unable to locate flash file [${FLASH}]"
  exit 1
fi

# make sure this script is executed as root
if [ "$EUID" -ne 0 ]
  then echo "ERROR (nx-flash:02) Please run as root"
  exit 1
fi

while true; do
  echo "Waiting for NX..."

  if [ $(lsusb | grep '0955:7e19' | wc -l) -ne 0 ]; then
    break
  fi

  echo " Apply power, hold down reset pin for 10 seconds, then release."
  echo

  sleep 3
done

echo "NX detected. Flashing..."
sudo "${FLASH}"
if [ $? -ne 0 ]; then
  echo "ERROR (nx-flash:03): NX flashing failure"
  exit 1
fi
echo "NX flashing finished"
