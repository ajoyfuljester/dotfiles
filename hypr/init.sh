#!/usr/bin/env bash

eject /dev/sr1

bash $XDG_CONFIG_DIRS/hypr/vars.sh

hyprpm reload

nm-applet &

hyprpaper &

clipse -listen

discord &
thunderbird &

anki &

sleep 3s
sudo -n ip link set wlp0s20f0u4 mode default

