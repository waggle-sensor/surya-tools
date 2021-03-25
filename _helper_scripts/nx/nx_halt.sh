#!/bin/bash

KEY=${1:-""}
NODE=${2:-""}

if [ ! -f "${KEY}" ]; then
  echo "Error (nx-halt:01): unable to locate SSH key file [${KEY}]"
  exit 1
fi

if [ -z "${NODE}" ]; then
  echo "Error (nx-halt:02): invalid Node IP address provided";
  exit 1
fi

# make sure this script is executed as root
if [ "$EUID" -ne 0 ]
  then echo "Error (nx-halt:03) Please run as root"
  exit 1
fi

# make sure we have a connection to the NX
FOUND=
for i in {1..30}; do
  ping -c1 ${NODE}
  if [ $? -eq 0 ]; then
    FOUND=1
    break;
  fi

  sleep 1
done

if [ -z "${FOUND}" ]; then
  echo "Error (nx-halt:04): unable to communicate to the NX"
  exit 1
fi

ssh-keygen -R "${NODE}"

# disable all LEDs and blink RED for shutdown (sleep for visibility)
ssh -q root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
  "echo '0' > /sys/class/leds/blue/brightness;" \
  "echo '0' > /sys/class/leds/green/brightness;" \
  "echo timer > /sys/class/leds/red/trigger"
sleep 2s

# attempt to shutdown the NX gracefully
SD_SUCCESS=
for i in {1..10}; do
  echo "Executing NX shutdown..."
  echo

  # execute shutdown in background
  ssh -q root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -f -x \
    "shutdown -h now"
  if [ $? -ne 0 ]; then
    echo "WARNING (nx-halt:05): system shutdown request error"
  fi

  echo "Shutting down NX, please wait..."
  echo
  # wait for the system to shutdown
  timeout 30s grep --line-buffered -m1 "CPU1: shutdown" < /dev/ttyUSB0
  if [ $? -ne 0 ]; then
    echo "WARNING (nx-halt:06): system did not shutdown safely"
  else
    SD_SUCCESS=1
    break
  fi
done

if [ -z "${SD_SUCCESS}" ]; then
  echo "WARNING (nx-halt:07): unable to gracefully shutdown"
fi
echo "Shutdown complete"
