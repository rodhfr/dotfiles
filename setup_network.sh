#!/bin/bash

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update package index and install iwd
echo "Updating package index and installing iwd..."
apt update && apt install -y iwd

# Define the network interface (change this as needed)
INTERFACE="wlan0"  # Replace with your actual interface name
NETWORK_FILE="/etc/systemd/network/${INTERFACE}.network"

# Update package index and install systemd-networkd (if necessary)
if ! systemctl is-active --quiet systemd-networkd; then
    echo "Installing systemd-networkd..."
    apt install -y systemd-networkd
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

# Function to connect to Wi-Fi
connect_to_wifi() {
    echo "Listing available Wi-Fi networks..."
    iwctl station "$INTERFACE" get-networks | head -n 10

    # Collect available SSIDs
    available_ssids=()
    while IFS= read -r line; do
        # Assuming the SSID is in the first column
        available_ssids+=("$line")
    done < <(iwctl station "$INTERFACE" get-networks | awk '{print $1}' | grep -v "^$" | head -n 10)

    echo "Please select a network by entering the corresponding number (1-${#available_ssids[@]}):"
    for i in "${!available_ssids[@]}"; do
        echo "$((i + 1)). ${available_ssids[i]}"
    done

    read -p "Enter the number of the Wi-Fi network you want to connect to: " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#available_ssids[@]}" ]; then
        echo "Invalid selection. Exiting."
        exit 1
    fi

    SSID="${available_ssids[$((choice - 1))]}"
    read -sp "Enter the password for the Wi-Fi network '${SSID}': " PASSWORD
    echo

    echo "Connecting to ${SSID}..."
    iwctl station "$INTERFACE" connect "$SSID" --passphrase "$PASSWORD"

    if [ $? -eq 0 ]; then
        echo "Successfully connected to ${SSID}."
    else
        echo "Failed to connect to ${SSID}. Please check the SSID and password."
    fi
}

# Call the function to connect to Wi-Fi
connect_to_wifi

# Function to remove NetworkManager and nmcli
remove_network_manager() {
    echo "Removing NetworkManager and nmcli..."

    # Check if NetworkManager is installed
    if dpkg -l | grep -q network-manager; then
        apt remove --purge -y network-manager
        echo "NetworkManager has been removed."
    else
        echo "NetworkManager is not installed."
    fi

    # Check if nmcli is installed
    if command -v nmcli &> /dev/null; then
        echo "nmcli has been removed."
    else
        echo "nmcli is not installed."
    fi

    # Clean up any unused dependencies
    apt autoremove -y
}

# Call the function to remove NetworkManager and nmcli
remove_network_manager

# Inform the user of success
echo "Network configuration for ${INTERFACE} has been set up with DHCP."
echo "You can check the status with: networkctl status"

