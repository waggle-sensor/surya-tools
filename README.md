# Wild Sage Node Factory Scripts

Included here are helper scripts for preparing a Wild Sage node in a factory
environment.  This includes scripts to prepare the individual compute units
(ex. NX and Raspberry Pi). Below you will find instructions on script usage.

## NX Prepare Script Overview

This script will take a NVidia NX (on a Connect Photon carrier board) and
flash it completely, ensure it performed Beehive/Beekeeper registration and
then shuts the system down so that power can be removed safely.

To flash with default `nvmflash.sh` file and SSH key file paths:

```
./nx_prepare.sh
```

To specific alternative `nvmflash.sh` and/or SSH key file paths:

```
./nx_prepare.sh -f <nvmflash.sh file path> -k <SSH key file path>
```

### Visual Indicators

During the preparation process the on-board LED (next to the ethernet jack)
will proceed through a series of colors and patterns to indicate process.

1. Off (no color): NX is flashing. This stage will last for several minutes.
2. Blue (blinking): NX is detected as online and waiting for registration.
3. Green (solid): Registration is complete.
4. Red (blinking): NX is shutting down (do **not** remove power).
5. Red (solid): NX is fully powered down and power can safely be removed.

### Example Terminal Output

```
./nx_prepare.sh -f /home/jswantek/workspace/custom_builds/hostname03/mfi_waggle_photon/nvmflash.sh -k ~/ecdsa-surya-sage-waggle
-------------------------
NX Flashing Recipe:
 Flash:		/home/jswantek/workspace/custom_builds/hostname03/mfi_waggle_photon/nvmflash.sh
 SSH Key:	/root/ecdsa-surya-sage-waggle
 NX IP:		ws-nxcore-prereg.lan
-------------------------
Waiting for NX...
 Apply power, hold down reset pin for 10 seconds, then release.

NX detected. Flashing...
Start flashing device: 2-1.1, PID: 6385
Ongoing processes: 6385
Ongoing processes: 6385

...

Ongoing processes: 6385
Ongoing processes:
Flash complete (SUCCESS)
NX flashing finished
-- (1/3) ----------------
NX Flashing COMPLETE!
-------------------------
Waiting for NX [ws-nxcore-prereg.lan] to come online...
 Connect ethernet cable to NX ethernet jack.

PING ws-nxcore-prereg.lan (192.168.2.113) 56(84) bytes of data.
From ubuntu-laptop.localdomain (192.168.2.108) icmp_seq=1 Destination Host Unreachable

--- ws-nxcore-prereg.lan ping statistics ---
1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0ms

...

Waiting for NX to come online...
 Connect ethernet cable to NX ethernet jack.

PING ws-nxcore-prereg.lan (192.168.2.113) 56(84) bytes of data.
64 bytes from ws-nxcore-prereg.lan (192.168.2.113): icmp_seq=1 ttl=64 time=2342 ms

--- ws-nxcore-prereg.lan ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 2342.481/2342.481/2342.481/0.000 ms
# Host ws-nxcore-prereg.lan found: line 1
/root/.ssh/known_hosts updated.
Original contents retained as /root/.ssh/known_hosts.old
Waiting for NX SSH services to come online...

Waiting for NX SSH services to come online...

NX detected on-online, waiting for registration...

...

NX detected on-online, waiting for registration...

Mar 31 20:37:47 ws-nxcore-prereg waggle_network_watchdog.py[4937]: INFO:root:connection ok
NX registration detected
-- (2/3) ----------------
NX registration COMPLETE!
-------------------------
PING ws-nxcore-prereg.lan (192.168.2.113) 56(84) bytes of data.
64 bytes from ws-nxcore-prereg.lan (192.168.2.113): icmp_seq=1 ttl=64 time=1.22 ms

--- ws-nxcore-prereg.lan ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.221/1.221/1.221/0.000 ms
# Host ws-nxcore-prereg.lan found: line 4
/root/.ssh/known_hosts updated.
Original contents retained as /root/.ssh/known_hosts.old
Executing NX shutdown...

Shutting down NX, please wait...

Connection to ws-nxcore-prereg.lan closed by remote host.
Binary file (standard input) matches
Shutdown complete
-- (3/3) ----------------
NX shutdown COMPLETE.
 You may remove power.
-------------------------
```