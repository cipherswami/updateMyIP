#!/bin/bash

##############################################################
# Author        : Aravind Potluri <aravindswami135@gmail.com>
# Description   : Installation script for IP monitoring setup.
# Distribution  : All systemd enabled Linux OS.
##############################################################

# Function to display banner
function banner {
    clear
    echo "##############################################################"
    echo "#------------------------------------------------------------#"
    echo "                   updateMyIP Uninstallation                 "
    echo "#------------------------------------------------------------#"
    echo "####################### INTENT LABs ##########################"
}

# Variables
SCRIPT_NAME="updateMyIP.sh"  # Name of the script
SCRIPT_SRC="linux/$SCRIPT_NAME"  # Source path for the script
SCRIPT_DST="/etc/NetworkManager/dispatcher.d/$SCRIPT_NAME"  # Destination path for the script

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo ""
    echo "[!] This script must be run as sudo" 1>&2
    echo ""
    exit 1
fi

# Display banner
banner

echo ""

# Install necessary packages
echo "Installing necessary packages..."
apt-get update
apt-get install -y curl network-manager

echo ""

# Ensure script file exists
if [ ! -f "$SCRIPT_SRC" ]; then
    echo "[!] Script $SCRIPT_SRC not found." 1>&2
    exit 1
fi

# Copy the script to /usr/local/bin and make it executable
echo "[+] Copying $SCRIPT_SRC to $SCRIPT_DST"
if cp "$SCRIPT_SRC" "$SCRIPT_DST" && chmod +x "$SCRIPT_DST"; then
    echo "[+] Successfully copied executable $SCRIPT_NAME"
else
    echo "[!] Failed to copy executable $SCRIPT_NAME" 1>&2
    exit 1
fi

echo ""

# Restart NetworkManager to apply changes
echo "[+] Restarting NetworkManager to apply changes..."
if systemctl restart NetworkManager; then
    echo "[+] NetworkManager restarted successfully"
else
    echo "[!] Failed to restart NetworkManager" 1>&2
    exit 1
fi

echo ""

echo "[#] Installation done :)"
echo ""
echo "[#] The script has been installed and configured."
