#!/bin/bash

# see man zscroll for documentation of the following parameters
/home/gmdev/.pyenv/shims/zscroll -l 30 \
        --delay 0.1 \
        --scroll-padding "  " \
        --match-command "$HOME/.config/polybar/get_spotify_status.sh --status" \
        --match-text "Playing" "--scroll 1" \
        --match-text "Paused" "--scroll 0" \
        --update-check true "$HOME/.config/polybar/get_spotify_status.sh" &

wait
