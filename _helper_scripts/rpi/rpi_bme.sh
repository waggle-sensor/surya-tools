#!/bin/bash

KEY=${1:-""}
NODE=${2:-""}
SENSOR=${3:-"bme680"}

if [ ! -f "${KEY}" ]; then
  echo "ERROR (rpi-bme:01): unable to locate SSH key file [${KEY}]"
  exit 1
fi

if [ -z "${NODE}" ]; then
  echo "ERROR (rpi-bme:02): invalid RPi IP address provided";
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
  echo "ERROR (rpi-bme:03): unable to communicate to the RPi"
  exit 1
fi

ssh-keygen -R "${NODE}"

# test all the pressure sensor
TESTS=(
  "/sys/bus/i2c/devices/1-0076/iio:device0/in_humidityrelative_input"
  "/sys/bus/i2c/devices/1-0076/iio:device0/in_humidityrelative_oversampling_ratio"
  "/sys/bus/i2c/devices/1-0076/iio:device0/in_pressure_input"
  "/sys/bus/i2c/devices/1-0076/iio:device0/in_pressure_oversampling_ratio"
  "/sys/bus/i2c/devices/1-0076/iio:device0/in_resistance_input"
  "/sys/bus/i2c/devices/1-0076/iio:device0/in_temp_input"
  "/sys/bus/i2c/devices/1-0076/iio:device0/in_temp_oversampling_ratio"
)

NAME="/sys/bus/i2c/devices/1-0076/iio:device0/name"

echo "Executing BME Pressure Sensor Test"
echo

if ! ssh pi@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x "cat $NAME | grep $SENSOR"; then
  echo "ERROR (rpi-bme:04): pressure sensor [$SENSOR] not found"
  exit 1
else
  echo "Pressure sensor [$SENSOR] found"
fi

for test in "${TESTS[@]}"; do
  if ! ssh pi@${NODE} -i ${KEY} -o "StrictHostKeyChecking no" -x "ls $test"; then
    echo "ERROR (rpi-bme:05): pressure sensor value [$test] not found"
    exit 1
  else
    echo "Pressure sensor [$SENSOR] value [$test] found"
  fi
done

echo "RPi pressure sensor test complete"
