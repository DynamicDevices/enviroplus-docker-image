#!/bin/bash

# Load in driver for MEMS microphone
insmod rpi0-i2s-audio.ko && 1

if [[ -z "${AUTORUN}" ]]; then
 ./sleep.sh
else
 ./runmqtt.sh
fi
