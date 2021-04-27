#!/bin/bash

KEY=${1:-""}
NODE=${2:-""}

if [ ! -f "${KEY}" ]; then
  echo "ERROR (rpi-halt:01): unable to locate SSH key file [${KEY}]"
  exit 1
fi

if [ -z "${NODE}" ]; then
  echo "ERROR (rpi-halt:02): invalid RPi IP address provided";
  exit 1
fi

# make sure we have a connection to the RPi
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
  echo "ERROR (rpi-halt:03): unable to communicate to the RPi"
  exit 1
fi

ssh-keygen -R "${NODE}"

# attempt to shutdown the RPi gracefully
for i in {1..10}; do
  echo "Executing RPi shutdown..."
  echo

  # execute shutdown in background
  ssh -q pi@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -f -x \
    "sudo shutdown -h now"
  if [ $? -ne 0 ]; then
    echo "WARNING (rpi-halt:04): system shutdown request error"
  else
    echo "System shutdown request sent, waiting for system to shutdown..."
    # wait for the system to shutdown, by testing ping to fail
    SHUTDOWN=
    for i in {1..10}; do
      ping -c1 ${NODE}
      if [ $? -ne 0 ]; then
        SHUTDOWN=1
        break;
      fi
      sleep 1
    done
    if [ -n "${SHUTDOWN}" ]; then
      # system shutdown success
      break;
    fi
  fi
done

echo "Shutdown complete"
