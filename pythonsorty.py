import re

# Prompt the user for the file path
file_path = input("Enter the file path: ")

with open(file_path, 'r') as file:
    data = file.read()
    ip_addresses = re.findall(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', data)
    sorted_ips = sorted(ip_addresses, key=lambda ip: tuple(map(int, ip.split('.'))))

for ip in sorted_ips:
    print(ip)
