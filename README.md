
# Balena Docker container for using the Pimoroni Enviro+ board

The Enviro+ is a lovely little integrated sensor board for the Raspberry Pi series of boards.

![EnviroPlus Picture](https://i.ibb.co/W31YvWr/image.png)

The Pimoroni Getting Started guide is [here](https://learn.pimoroni.com/tutorial/sandyj/getting-started-with-enviro-plus)

## Setup

My container  should have all needed dependencies and the various examples

You will need to slightly reconfigure your RPi if you are using the particulate sensor as the serial console gets in the way.

If using Balena as your embedded Docker platform you can do something like this

```
#First disable read-only rootfs:
mount -o remount,rw /

# Then mask the serial getty service:
systemctl mask serial-getty@serial0.service

reboot
```

You also need a couple of device settings for the I2C and I2S bus

- DT parameters needs to be `"i2c_arm=on","spi=on","audio=on","i2s=on"`
- DT overlays needs to be `pi3-miniuart-bt`

For more details on this see the Pimoroni Enviro+ [repo](https://github.com/pimoroni/enviroplus-python)

## Setup Problems downloading container update [Solved]

On the Pi Zero it can take a while to extract container images, particularly if they are quite large.

What can then happen is that a Balena watchdog can then timeout and restart the download, so you end up downloading over and over (quite frustrating!)

See the conversation [here](https://forums.balena.io/t/persistent-failed-to-download-image-due-to-connect-econnrefused-var-run-balena-engine-sock-error/114001/57) where I investigated this.

To resolve you need to edit the timeout on the watchdog and to do this you need to open a terminal in the Host OS, then:

```
# First disable read-only rootfs:
mount -o remount,rw /

# Edit the service
vi /etc/systemd/system/balena-engine.service

# Change Watchdog Sec in that file to increase it...
WatchdogSec=3600

# Remount ro
mount -o remount,ro /

reboot
```

## Kernel Module Versioning

Also there is an I2S audio driver which is built specifically against the underlying Linux kernel

Check the BelenaOS version of your installation and change this line in `Dockerfile.template`

`ENV VERSION '2.54.2+rev1.prod'`

This is built and included for this BalenaOS in the `sensors` image. To load in use

```
insmod rpi0-i2s-audio.ko
```

To check use

```
arecord -l
```

You should see an audio device like this

```
root@539cd3741a89:/usr/src/app# arecord -l
**** List of CAPTURE Hardware Devices ****
card 1: sndrpi0simpleca [snd_rpi0_simple_card], device 0: simple-card_codec_link snd-soc-dummy-dai-0 [simple-card_codec_link snd-soc-dummy-dai-0]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```

## Environment Variables

There's a `sensors` container that runs up. This starts `autorun.sh` which checks for an `AUTORUN` environment variable. If this isn't present it loops over a sleep function which allows you to debug. Otherwise the container would exit. With this set it runs a `runmqtt.sh` script which currently runs the default Pimoroni `mqtt-all.py` script with parameters on the command-line

| Environment Variable | Description |
| -------------------- | ----------- |
| AUTORUN              | If present we start the main task, otherwise sleep |
| MQTT_BROKER          | MQTT broker host to which to publish data |
| MQTT_PORT            | MQTT broker port |
| MQTT_TOPIC           | MQTT topic we publish to |

