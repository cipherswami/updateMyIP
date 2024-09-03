import http.client
import json
import socket
import subprocess

# Load the password from an external file
def load_password(file_path='password.txt.creds'):
    with open(file_path, 'r') as file:
        return file.read().strip()

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
        print(f"Failed to get IP address: {e}")
        return '0.0.0.0'

# Get the MAC address
def get_mac_address():
    result = subprocess.check_output(["ifconfig"], universal_newlines=True)
    import re
    match = re.search(r"(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)", result)
    return match.group(0) if match else '00:00:00:00:00:00'

# Define the endpoint and data
host = 'intentlab.iitk.ac.in'
endpoint = '/api/update.php'
data = {
    'password': load_password(), # You can just replace with password
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
    conn.request('POST', endpoint, body=json_data, headers=headers)
    
    # Get the response
    response = conn.getresponse()
    response_data = response.read().decode()

    # Check the response
    if response.status == 200:
        print("Data sent successfully!")
        print("Response: ", response_data)
    else:
        print(f"Failed to send data. Status code: {response.status}")
        print("Response content:", response_data)
except Exception as e:
    print(f"Request failed: {e}")
finally:
    conn.close()
