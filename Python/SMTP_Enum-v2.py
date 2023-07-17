#!/usr/bin/python
# python3

import socket
import sys

def is_ipv4(ip):
    """Check if ip is a valid IPv4 address."""
    try:
        socket.inet_aton(ip)
        return True
    except socket.error:
        return False

if len(sys.argv) < 3:
	print("Usage: smtp-vrfy.py <username> <tar_ip/hostname> [<tar_port>] ")
	sys.exit(0)

#Create socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to server
ip_or_hostname = sys.argv[2]
port = int(sys.argv[3]) if len(sys.argv) > 3 else 25  # Default to 25 if not provided

# If the provided argument is not a valid IPv4 address, try to resolve it as a hostname
if not is_ipv4(ip_or_hostname):
    try:
        ip_or_hostname = socket.gethostbyname(ip_or_hostname)
    except socket.gaierror:
        print(f"Failed to resolve {ip_or_hostname}.")
        sys.exit(1)

connect = s.connect((ip_or_hostname, port))

# Banner grab
banner = s.recv(1024)
print(banner)

#VRFY a user
user = (sys.argv[1]).encode()
s.send(b'VRFY ' + user + b'\r\n')
result = s.recv(1024)

print(result)

# Close socket
s.close()
