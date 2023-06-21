#This is version 2

import re
import sys

# Check if the file path is provided as a command line argument
if len(sys.argv) < 2:
    print("Please provide the file path as the second argument.")
    sys.exit(1)

# Get the file path from the command line argument
file_path = sys.argv[1]

# Extract the file name and extension
file_name, file_extension = file_path.rsplit('.', 1)

# Create the output file path
output_file_path = f"{file_name}_sorted.{file_extension}"

with open(file_path, 'r') as file:
    data = file.read()
    ip_addresses = re.findall(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', data)
    sorted_ips = sorted(ip_addresses, key=lambda ip: tuple(map(int, ip.split('.'))))

with open(output_file_path, 'w') as output_file:
    for ip in sorted_ips:
        output_file.write(ip + '\n')

print(f"Sorted IP addresses saved to {output_file_path}")









#########################################################33
###Below is version 1
'''
import re

# Prompt the user for the file path
file_path = input("Enter the file path: ")

# Extract the file name and extension
file_name, file_extension = file_path.rsplit('.', 1)

# Create the output file path
output_file_path = f"{file_name}_sorted.{file_extension}"

with open(file_path, 'r') as file:
    data = file.read()
    ip_addresses = re.findall(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', data)
    sorted_ips = sorted(ip_addresses, key=lambda ip: tuple(map(int, ip.split('.'))))

with open(output_file_path, 'w') as output_file:
    for ip in sorted_ips:
        output_file.write(ip + '\n')

print(f"Sorted IP addresses saved to {output_file_path}")
'''
