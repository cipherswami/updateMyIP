#!/bin/bash

################################################
# Script for Monitoring IP Changes and Updating
################################################

#########################################
############ ENTER Password #############
ACTUAL_PASSWORD="PASSWORD_HERE"
#########################################

# Variables
LOG_TAG="updateMyIP"
INTERFACE=$(ip route | grep '^default' | awk '{print $5}')
STATUS=$(cat /sys/class/net/$INTERFACE/operstate)
IP_FILE_PATH="/tmp/currentIP.txt"
ENDPOINT="/api/update.php"
HOST="intentlab.iitk.ac.in"

# Function to log messages to syslog
function log_message {
    local MESSAGE=$1
    local LEVEL=${2:-INFO}
    logger -t "$LOG_TAG" "$LEVEL - $MESSAGE"
}

# Load password
load_password() {
    local dev=$1
    local password=""

    case "$dev" in
        0)
            # Use the global ACTUAL_PASSWORD
            password="$ACTUAL_PASSWORD"
            ;;
        1)
            # Load password from file (USED for testing)
            local file_path="/tmp/password.txt.creds"
            if [ -f "$file_path" ]; then
                password=$(cat "$file_path")
            else
                log_message "$file_path not found." "ERROR"
                exit 1
            fi
            ;;
        *)
            log_message "Invalid device option $dev." "ERROR"
            exit 1
            ;;
    esac

    echo "$password"
}

# Get PC name
get_pc_name() {
    hostname
}

# Get IP address
get_ip_address() {
    ip route get 8.8.8.8 | awk '{print $7;exit}'
}

# Get MAC address
get_mac_address() {
    local ip_address=$1
    local interface=$(ip -o -4 addr list | grep "$ip_address" | awk '{print $2}')
    if [ -n "$interface" ]; then
        ip link show "$interface" | awk '/link\/ether/ {print $2}'
    else
        echo "00:00:00:00:00:00"
    fi
}

# Function to update IP information
update_ip_info() {
    local password=$(load_password 0)
    local ip_address=$(get_ip_address)
    local mac_address=$(get_mac_address $ip_address)
    local pc_name=$(get_pc_name)

    # Create JSON payload
    local json_data=$(printf '{
        "password": "%s",
        "mac_address": "%s",
        "ip_address": "%s",
        "pc_name": "%s"
    }' "$password" "$mac_address" "$ip_address" "$pc_name")

    # Send the POST request
    local response=$(curl -s -w "%{http_code}" -o /tmp/response_body.txt \
        -X POST "$HOST$ENDPOINT" \
        -H "Content-Type: application/json" \
        -d "$json_data")

    # Check the response
    local response_body=$(cat /tmp/response_body.txt)
    if [ "$response" -eq 200 ]; then
        log_message "Data sent successfully!"
        log_message "Response: $response_body"
    else
        log_message "Failed to send data. Status code: $response"
        log_message "Response content: $response_body" "ERROR"
    fi
    log_message "Connection closed."
}

# Log the invocation of the script
log_message "Invoked for interface $INTERFACE"

# Check if the interface status is 'up'
if [ "$STATUS" == "up" ]; then
    # Fetch the current IP address
    CURRENTIP=$(hostname -I | awk '{print $1}')
    
    # Load the previous IP address from a file
    if [ -f "$IP_FILE_PATH" ]; then
        PREVIOUS_IP=$(cat "$IP_FILE_PATH")
    else
        PREVIOUS_IP=""
    fi

    # Compare IP addresses
    if [ "$CURRENTIP" != "$PREVIOUS_IP" ]; then
        echo "$CURRENTIP" > "$IP_FILE_PATH"
        # Update IP information and log the action
        update_ip_info
    else
        log_message "No IP address change detected."
    fi
else
    log_message "Interface $INTERFACE is down. No action taken."
fi
