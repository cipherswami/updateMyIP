#!/bin/bash

##########################################
# Dispatcher Script to monitor IP changes
##########################################

# Variables
LOG_TAG="IP_MONITOR"
INTERFACE=$(ip route | grep '^default' | awk '{print $5}')
STATUS=$(cat /sys/class/net/$INTERFACE/operstate)
YOUR_SCRIPT="/usr/local/bin/updateMyIP.py"
IP_FILE_PATH="/tmp/current_ip.txt"

# Function to log messages to syslog
function log_message {
    local MESSAGE=$1
    logger -t "$LOG_TAG" "$MESSAGE"
}

# Log the invocation of the script
log_message "Dispatcher script called for interface $INTERFACE"

# Check if the interface status is 'up'
if [ "$STATUS" == "up" ]; then
    # Fetch the current IP address
    CURRENT_IP=$(hostname -I | awk '{print $1}')
    
    # Load the previous IP address from a file
    if [ -f "$IP_FILE_PATH" ]; then
        PREVIOUS_IP=$(cat "$IP_FILE_PATH")
    else
        PREVIOUS_IP=""
    fi

    # Compare IP addresses
    if [ "$CURRENT_IP" != "$PREVIOUS_IP" ]; then
        echo "$CURRENT_IP" > "$IP_FILE_PATH"
        # Run your Python script and log the action
        python3 "$YOUR_SCRIPT" && log_message "Executed IP Updater Python script" || log_message "Failed to execute IP Updater Python script"
    else
        log_message "No IP address change detected."
    fi
else
    log_message "Interface $INTERFACE is down. No action taken."
fi
