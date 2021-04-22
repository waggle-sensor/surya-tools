#!/bin/bash

KEY=${1:-""}
NODE=${2:-""}
export TTY=${3:-""}

if [ ! -f "${KEY}" ]; then
  echo "Error (nx-halt:01): unable to locate SSH key file [${KEY}]"
  exit 1
fi

if [ -z "${NODE}" ]; then
  echo "Error (nx-halt:02): invalid Node IP address provided";
  exit 1
fi

if [ -z "${TTY}" ]; then
  echo "Error (nx-halt:03): invalid Node Serial TTY provided";
  exit 1
fi

# make sure this script is executed as root
if [ "$EUID" -ne 0 ]
  then echo "Error (nx-halt:04) Please run as root"
  exit 1
fi

# ensure the tty is setup for the right speed, etc.
stty -F $TTY 115200 brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -echo min 100 time 2

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
  echo "Error (nx-halt:05): unable to communicate to the NX"
  exit 1
fi

ssh-keygen -R "${NODE}"

# get the node's ID before shutdown
nodeid=$(ssh -q root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
  'cat /etc/waggle/node-id')
nodeid_short=${nodeid: -3}

# disable all LEDs and blink RED for shutdown (sleep for visibility)
ssh -q root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
  "echo '0' > /sys/class/leds/blue/brightness;" \
  "echo '0' > /sys/class/leds/green/brightness;" \
  "echo timer > /sys/class/leds/red/trigger"
sleep 2s

# attempt to shutdown the NX gracefully
SD_SUCCESS=
for i in {1..3}; do
  echo "Executing NX shutdown..."
  echo

  # execute shutdown in background
  ssh -q root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -f -x \
    "shutdown -h now"
  if [ $? -ne 0 ]; then
    echo "WARNING (nx-halt:06): system shutdown request error"
  fi

  echo "Shutting down NX, please wait..."
  echo
  # wait for the system to shutdown
  timeout 30s bash -c -- '''
  while IFS= read -r line; do
    if echo $line | grep -m1 -E "CPU[[:digit:]]+: shutdown"; then
      echo "Proper shutdown detected"
      break
    fi
  done < $TTY
'''
  if [ $? -ne 0 ]; then
    echo "WARNING (nx-halt:07): system did not shutdown safely"
  else
    SD_SUCCESS=1
    break
  fi
done

if [ -z "${SD_SUCCESS}" ]; then
  echo "WARNING (nx-halt:08): unable to gracefully shutdown"
fi
echo "Shutdown complete"
echo -e " - Node ID:\t\t$nodeid"
echo -e " - Node ID (short):\t$nodeid_short"
