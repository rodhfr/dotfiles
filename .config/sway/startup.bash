#!/usr/bin/env bash

swaymsg workspace 1
swaymsg exec flatpak run com.adamcake.Bolt
sleep 1
swaymsg workspace 2
swaymsg exec flatpak run com.google.Chrome
sleep 1
swaymsg workspace 3
swaymsg exec alacritty
