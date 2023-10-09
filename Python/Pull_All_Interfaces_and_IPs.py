import subprocess

def get_interface_ips():
    # Initialize a dictionary to hold the interface names and their IPs
    interface_ips = {}
    current_iface = None
    
    # Get the list of network interfaces
    try:
        output = subprocess.check_output("ip addr show", shell=True).decode('utf-8')
        lines = output.strip().split("\n")
        
        for line in lines:
            line = line.strip()
            if line:
                if not line[0].isdigit():
                    # This line contains an IP address
                    if 'inet ' in line:
                        ip_addr = line.split(' ')[1].split('/')[0]
                        if current_iface:
                            if current_iface not in interface_ips:
                                interface_ips[current_iface] = []
                            interface_ips[current_iface].append(ip_addr)
                else:
                    # This line contains an interface name
                    current_iface = line.split(":")[1].strip().split(' ')[0]
                    
    except Exception as e:
        print(f"An error occurred: {e}")

    return interface_ips

# Get and present IPs
interface_ips = get_interface_ips()
print("IP interfaces and respective IPv4 addresses:")
for interface, ips in interface_ips.items():
    print(f"{interface}: {', '.join(ips)}")
