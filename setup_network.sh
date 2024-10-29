#!/bin/bash

# Define the network interface (change this as needed)
INTERFACE="wlan0"  # Replace with your actual interface name
NETWORK_FILE="/etc/systemd/network/${INTERFACE}.network"

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update package index and install systemd-networkd (if necessary)
if ! systemctl is-active --quiet systemd-networkd; then
    echo "Installing systemd-networkd..."
    # For Debian/Ubuntu
    apt update && apt install -y systemd-networkd
    # For Arch-based systems
    # pacman -Sy --noconfirm systemd-networkd
fi

# Create a network configuration file for the interface
echo "Creating network configuration for ${INTERFACE}..."
cat <<EOL > "$NETWORK_FILE"
[Match]
Name=${INTERFACE}

[Network]
DHCP=yes
EOL

# Enable and start systemd-networkd
echo "Enabling and starting systemd-networkd..."
systemctl enable systemd-networkd
systemctl start systemd-networkd

# Inform the user of success
echo "Network configuration for ${INTERFACE} has been set up with DHCP."
echo "You can check the status with: networkctl status"
