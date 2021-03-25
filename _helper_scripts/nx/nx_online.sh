#!/bin/bash

KEY=${1:-""}
NODE=${2:-""}

if [ ! -f "${KEY}" ]; then
  echo "Error (nx-online:01): unable to locate SSH key file [${KEY}]"
  exit 1
fi

if [ -z "${NODE}" ]; then
  echo "Error (nx-online:02): invalid Node IP address provided";
  exit 1
fi

while true; do
  echo "Waiting for NX [${NODE}] to come online..."
  echo " Connect ethernet cable to NX ethernet jack."
  echo

  ping -c1 ${NODE}
  if [ $? -eq 0 ]; then
    break;
  fi

  sleep 1
done

ssh-keygen -R "${NODE}"

# try for 30 seconds to set the blinking registration detection LED
for i in {1..30}; do
  echo "Waiting for NX SSH services to come online..."
  echo

  # set led to blinking blue to indicate waiting for registration (sleep for visibility)
  ssh -q root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
    "echo '0' > /sys/class/leds/red/brightness;" \
    "echo '0' > /sys/class/leds/green/brightness;" \
    "echo 'timer' > /sys/class/leds/blue/trigger"
  if [ $? -eq 0 ]; then
    sleep 2s
    break
  fi

  sleep 1
done

while true; do
  echo "NX detected on-online, waiting for registration..."
  echo

  ssh -q root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
    "journalctl -b0 --no-pager -u waggle-network-watchdog | grep -m1 'connection ok'"
  if [ $? -eq 0 ]; then
    break;
  fi

  sleep 1
done

# set led to solid green to indicate registration complete
ssh -q root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
  "echo 'none' > /sys/class/leds/blue/trigger;" \
  "echo '0' > /sys/class/leds/blue/brightness;" \
  "echo '255' > /sys/class/leds/green/brightness"
echo "NX registration detected"
