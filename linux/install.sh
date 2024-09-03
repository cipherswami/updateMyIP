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
    echo "                      IP Monitor Installation                 "
    echo "#------------------------------------------------------------#"
    echo "####################### INTENT LABs ##########################"
}

# Variables
DISPATCHER_SCRIPT_NAME="99-ip-change.sh" # Name of Dispatcer script
PYTHON_SCRIPT_SRC="../src/updateMyIP.py"  # Source path for the Python script
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

# Ensure dispatcher script exists
if [ ! -f "$DISPATCHER_SCRIPT_NAME" ]; then
    echo "[!] Dispatcher script $DISPATCHER_SCRIPT_NAME not found. Please make sure it's in the current directory." 1>&2
    exit 1
fi

# Ensure Python script exists
if [ ! -f "$PYTHON_SCRIPT_SRC" ]; then
    echo "[!] Python script $PYTHON_SCRIPT_SRC not found. Please make sure it's in ../src directory." 1>&2
    exit 1
fi

# Install necessary packages
echo "[+] Installing required packages..."
echo ""
if apt-get update && apt-get install -y python3 python3-pip network-manager; then
    echo ""
    echo "[+] Done"
else
    echo "[!] Failed to install packages" 1>&2
    exit 1
fi

echo ""

# Copy the Python script to /usr/local/bin and make it executable
echo "[+] Copying $PYTHON_SCRIPT_SRC to $PYTHON_SCRIPT_DST"
if cp "$PYTHON_SCRIPT_SRC" "$PYTHON_SCRIPT_DST" && chmod +x "$PYTHON_SCRIPT_DST"; then
    echo "[+] Successfully copied executable $PYTHON_SCRIPT_SRC"
else
    echo "[!] Failed to copy executable $PYTHON_SCRIPT_SRC" 1>&2
    exit 1
fi

echo ""

# Move dispatcher script to NetworkManager dispatcher directory
echo "[+] Installing NetworkManager dispatcher script..."
if cp "$DISPATCHER_SCRIPT_NAME" /etc/NetworkManager/dispatcher.d/ && chmod +x /etc/NetworkManager/dispatcher.d/"$DISPATCHER_SCRIPT_NAME"; then
    echo "[+] Successfully installed $DISPATCHER_SCRIPT_NAME"
else
    echo "[!] Failed to install $DISPATCHER_SCRIPT_NAME" 1>&2
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
echo "[#] The dispatcher script and Python script are installed and configured."
