#!/bin/bash

##############################################################
# Author        : Aravind Potluri <aravindswami135@gmail.com>
# Description   : Uninstallation script for IP monitoring setup.
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
SCRIPT_DST="/etc/NetworkManager/dispatcher.d/$SCRIPT_NAME"  # Destination path for the script
IP_FILE_PATH="/tmp/currentIP.txt"  # Path to the IP file

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

# Remove the script from NetworkManager dispatcher directory
if [ -f "$SCRIPT_DST" ]; then
    echo "[+] Removing $SCRIPT_DST"
    if rm "$SCRIPT_DST"; then
        echo "[+] Successfully removed $SCRIPT_NAME"
    else
        echo "[!] Failed to remove $SCRIPT_NAME" 1>&2
        exit 1
    fi
else
    echo "[!] $SCRIPT_NAME not found in $SCRIPT_DST"
fi

echo ""

# Remove the IP file if it exists
if [ -f "$IP_FILE_PATH" ]; then
    echo "[+] Removing $IP_FILE_PATH"
    if rm "$IP_FILE_PATH"; then
        echo "[+] Successfully removed $IP_FILE_PATH"
    else
        echo "[!] Failed to remove $IP_FILE_PATH" 1>&2
    fi
else
    echo "[!] $IP_FILE_PATH not found"
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

echo "[#] Uninstallation done :)"
echo ""
echo "[#] The script and IP file have been removed, and NetworkManager has been restarted."
