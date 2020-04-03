#!/bin/bash

PLAYER_STATUS=$(playerctl status)

if [[ $PLAYER_STATUS == "Playing"  ]]; then
	playerctl pause
fi

dm-tool switch-to-greeter
