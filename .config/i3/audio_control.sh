#!/bin/bash

SINKS=`pacmd list-sinks | grep 'index:' | cut -b12`

if [ "$1" == "mute" ]; then
	for sink in $SINKS; do
		pactl set-sink-mute "$sink" toggle
	done
	exit
elif [ "$1" == "raise"  ]; then
	VOLUME='+5%'
else
	VOLUME='-5%'
fi

for sink in $SINKS; do
	pactl set-sink-volume "$sink" "$VOLUME"
done
