#!/usr/bin/python
# python3

import socket
import sys

if len(sys.argv) != 4:
	print("Usage: smtp-vrfy.py <username> <tar_ip> <tar_port> ")
	sys.exit(0)

#Create socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to server
ip = sys.argv[2]
port = int(sys.argv[3])  # Convert the port to an integer
connect = s.connect((ip,port))

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
