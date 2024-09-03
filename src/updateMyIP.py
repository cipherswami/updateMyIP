import http.client
import json
import socket
import subprocess
import logging
import logging.handlers

# Setup syslog logging
syslog_handler = logging.handlers.SysLogHandler(address='/dev/log')
formatter = logging.Formatter('%(name)s: %(levelname)s - %(message)s')
syslog_handler.setFormatter(formatter)

logger = logging.getLogger('updateMyIP')
logger.addHandler(syslog_handler)
logger.setLevel(logging.INFO)

def log_message(message, level=logging.INFO):
    if level == logging.ERROR:
        logger.error(message)
    else:
        logger.info(message)

def load_password(dev=0):
    if dev == 0:
        # Return your weblogin password
        return "YOUR_ACTUAL_PASSWORD_HERE"
    elif dev == 1:
        # Load password from file (USED for testing)
        file_path='password.txt.creds'
        try:
            with open(file_path, 'r') as file:
                return file.read().strip()
        except FileNotFoundError:
            log_message(f"Error: {file_path} not found.", logging.ERROR)
            return None

# Get the PC name
def get_pc_name():
    return socket.gethostname()

# Get the IP address
def get_ip_address():
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(('8.8.8.8', 80))
            ip_address = s.getsockname()[0]
        return ip_address
    except Exception as e:
        log_message(f"Failed to get IP address: {e}", logging.ERROR)
        return '0.0.0.0'

# Get the MAC address
def get_mac_address():
    try:
        result = subprocess.check_output(["ifconfig"], universal_newlines=True)
        import re
        match = re.search(r"(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)", result)
        return match.group(0) if match else '00:00:00:00:00:00'
    except Exception as e:
        log_message(f"Failed to get MAC address: {e}", logging.ERROR)
        return '00:00:00:00:00:00'

# Define the endpoint and data
host = 'intentlab.iitk.ac.in'
endpoint = '/api/update.php'
data = {
    'password': load_password(),  # You can just replace with password
    'mac_address': get_mac_address(),
    'ip_address': get_ip_address(),
    'pc_name': get_pc_name()
}

# Convert data to JSON
json_data = json.dumps(data)

# Create a connection to the server
conn = http.client.HTTPConnection(host)
headers = {
    'Content-type': 'application/json',
    'Content-Length': str(len(json_data))
}

# Send the POST request
try:
    log_message("Sending POST request to the server...")
    conn.request('POST', endpoint, body=json_data, headers=headers)

    # Get the response
    response = conn.getresponse()
    response_data = response.read().decode()

    # Check the response
    if response.status == 200:
        log_message("Data sent successfully!")
        log_message(f"Response: {response_data}")
    else:
        log_message(f"Failed to send data. Status code: {response.status}", logging.ERROR)
        log_message(f"Response content: {response_data}", logging.ERROR)
except Exception as e:
    log_message(f"Request failed: {e}", logging.ERROR)
finally:
    conn.close()
    log_message("Connection closed.")
