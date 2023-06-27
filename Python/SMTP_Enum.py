#!/usr/bin/python
# python3

import socket
importsys

if len(sys.argv) != 3:
	print("Usage: smtp-vrfy.py <username> <tar_ip>")
	sys.exit(0)

#Create socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to server
ip = sys.argv[2]
connect = s.connect((ip,25))

# Banner grab
banner = s.recv(1024)

print(banner)
# Old code: https://github.com/carnal0wnage/pentesty_scripts/blob/master/smtp/smtp-vrfy.py

#VRFY a user
user = (sys.argv[1]).encode()
s.send(b'VRFY ' + user + b'\r\n')
result = s.recv(1024)

print(result)

# Close socket
s.close()
