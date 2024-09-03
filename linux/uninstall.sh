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
    echo "                    IP Monitor Uninstall                      "
    echo "#------------------------------------------------------------#"
    echo "####################### INTENT LABs ##########################"
}

# Variables
DISPATCHER_SCRIPT_NAME="99-ip-change.sh" # Name of Dispatcher script
PYTHON_SCRIPT_DST="/usr/local/bin/updateMyIP.py"  # Destination path for the Python script

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

# Remove the Python script
echo "[+] Removing $PYTHON_SCRIPT_DST"
if rm -f "$PYTHON_SCRIPT_DST"; then
    echo "[+] Successfully removed $PYTHON_SCRIPT_DST"
else
    echo "[!] Failed to remove $PYTHON_SCRIPT_DST" 1>&2
    exit 1
fi

echo ""

# Remove the dispatcher script
echo "[+] Removing NetworkManager dispatcher script..."
if rm -f /etc/NetworkManager/dispatcher.d/"$DISPATCHER_SCRIPT_NAME"; then
    echo "[+] Successfully removed $DISPATCHER_SCRIPT_NAME"
else
    echo "[!] Failed to remove $DISPATCHER_SCRIPT_NAME" 1>&2
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

echo "[#] Uninstallation complete."
echo ""
echo "[#] The dispatcher script and Python script have been removed."
