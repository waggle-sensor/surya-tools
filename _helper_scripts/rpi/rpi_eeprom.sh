#!/bin/bash

KEY=${1:-""}
NODE=${2:-""}

if [ ! -f "${KEY}" ]; then
  echo "Error (rpi-eeprom:01): unable to locate SSH key file [${KEY}]"
  exit 1
fi

if [ -z "${NODE}" ]; then
  echo "Error (rpi-eeprom:02): invalid Node IP address provided";
  exit 1
fi

while true; do
  echo "Waiting for RPi [${NODE}] to come online..."
  echo " Connect ethernet cable to RPi ethernet jack."
  echo

  ping -c1 ${NODE}
  if [ $? -eq 0 ]; then
    break;
  fi

  sleep 1
done

ssh-keygen -R "${NODE}"

while true; do
  echo "RPi detected on-online, waiting for eeprom programming to complete..."
  echo

  ssh pi@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
    "cat /etc/rc.local.logs  | grep 'EEPROM update pending. Please reboot to apply the update.'"
  if [ $? -eq 0 ]; then
    break;
  fi

  # test to see if the eeprom has already been programmed
  ssh pi@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
    "cat /etc/rc.local.logs  | grep 'Bootconf already set correctly, reboot for pxe'"
  if [ $? -eq 0 ]; then
    echo "WARNING (rpi-eeprom:03) EEPROM already programmed."
    break;
  fi

  sleep 1
done

echo "RPi EEPROM programming complete"
