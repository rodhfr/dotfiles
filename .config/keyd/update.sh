#!/bin/bash
set -e

echo "Resetting /etc/keyd..."
sudo rm -rf /etc/keyd
sudo mkdir -p /etc/keyd/
echo "OK."

echo "Copying include files..."
for f in /home/rodhfr/.config/keyd/include/*; do
  [ -e "$f" ] || continue
  echo "Copying $(basename "$f")"
  sudo cp "$f" /etc/keyd/
done
echo "OK."

echo "Copying config files..."
for f in /home/rodhfr/.config/keyd/*.conf; do
  [ -e "$f" ] || continue
  echo "Copying $(basename "$f")"
  sudo cp "$f" /etc/keyd/
done
echo "OK."

echo "Restarting keyd..."
sudo systemctl enable --now keyd
sudo systemctl restart keyd
sudo keyd reload
echo "Done."
