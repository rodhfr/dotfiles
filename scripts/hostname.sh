#!/usr/env/bin bash

# Ask for hostname
read -rp "Enter hostname: " HOSTNAME
sudo hostnamectl set-hostname "$HOSTNAME"
