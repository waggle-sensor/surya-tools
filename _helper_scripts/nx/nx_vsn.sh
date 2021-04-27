#!/bin/bash

KEY=${1:-""}
NODE=${2:-""}
VSN=${3:-""}

if [ ! -f "${KEY}" ]; then
  echo "Error (nx-vsn:01): unable to locate SSH key file [${KEY}]"
  exit 1
fi

if [ -z "${NODE}" ]; then
  echo "Error (nx-vsn:02): invalid Node IP address provided";
  exit 1
fi

if [ -z "${VSN}" ]; then
  echo "Error (nx-vsn:03): invalid VSN provided";
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
  echo "Error (nx-vsn:05): unable to communicate to the NX"
  exit 1
fi

ssh-keygen -R "${NODE}"

# attempt to program the VSN
VSN_SUCCESS=
for i in {1..3}; do
  echo "Programming the VSN [$VSN]..."
  echo

  if ! ssh root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
    "echo $VSN > /etc/waggle/vsn"; then
    echo "WARNING (nx-vsn:06): VSN program error"
    sleep 2s
    continue
  fi

  # validate programmed correctly
  if ! ssh root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
    "cat /etc/waggle/vsn | grep $VSN"; then
    echo "WARNING (nx-vsn:07): VSN not programmed to [$VSN]"
    sleep 2s
    continue
  else
    echo "VSN [$VSN] programmed"
    VSN_SUCCESS=1
    break
  fi
done

if [ -z "${VSN_SUCCESS}" ]; then
  echo "ERROR (nx-vsn:08): unable to program VSN"
  exit 1
fi

# set LEDs purple (sleep for visibility)
ssh -q root@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x \
  "echo '100' > /sys/class/leds/blue/brightness;" \
  "echo '0' > /sys/class/leds/green/brightness;" \
  "echo '100' > /sys/class/leds/red/brightness;"
sleep 2s

echo "VSN [$VSN] Program success"
