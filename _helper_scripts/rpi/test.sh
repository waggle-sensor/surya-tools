ssh pi@raspberrypi.lan -i ~/.ssh/ecdsa-surya-sage-waggle -x 'cat /etc/rc.local.logs  | grep "EEPROM update pending. Please reboot to apply the update."'
