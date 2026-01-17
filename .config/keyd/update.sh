#!/bin/bash
rm -rf /home/rodhfr/.config/keyd/
mkdir -p /home/rodhfr/.config/keyd/
cp -rf ./* /home/rodhfr/.config/keyd/
sudo sh /home/rodhfr/.config/keyd/install.sh
echo "Keyd config reloaded"
