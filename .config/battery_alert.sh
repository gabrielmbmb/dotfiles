#!/bin/bash

export XDG_RUNTIME_DIR="/run/user/1000"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
export XAUTHORITY="/home/gmdev/.Xauthority"
export DISPLAY=":0"

IS_CHARGING="$(cat /sys/class/power_supply/ADP0/online)"
BATTERY_LEVEL="$(cat /sys/class/power_supply/BAT0/capacity)"
BATTERY_THRESHOLD_DOWN="10"
BATTERY_THRESHOLD_UP="95"

if [ $BATTERY_LEVEL -lt $BATTERY_THRESHOLD_DOWN ] && [ $IS_CHARGING -eq "0" ]; then
	dunstify -u critical \
	-t 3000 "Low Battery" "Plug in to AC or Suspend inmediately"
	
	paplay /usr/share/sounds/freedesktop/stereo/window-attention.oga
fi

if [ $BATTERY_LEVEL -gt $BATTERY_THRESHOLD_UP ] && [ $IS_CHARGING -eq "1" ]; then
	dunstify -t 3000 "Battery Charged" "Unplug the battery charger"
	paplay /usr/share/sounds/freedesktop/stereo/window-question.oga
fi
