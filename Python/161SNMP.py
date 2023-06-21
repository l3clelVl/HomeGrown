#This is ver 3.4
import subprocess
import re
import sys

# Step 1: Create community.tmp file
community_strings = ["public", "private", "manager"]
with open("community.tmp", "w") as file:
    file.write("\n".join(community_strings))

# Step 2: Run onesixtyone with community.tmp file
onesixtyone_command = ["onesixtyone", "-i", sys.argv[1], "-c", "community.tmp"]
onesixtyone_output = subprocess.check_output(onesixtyone_command).decode().splitlines()

# Step 3: Extract IP address and community
ip_regex = r"(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"
community_regex = r"\[([\w-]+)\]"

var1 = ""
var2 = ""

for line in onesixtyone_output:
    ip_match = re.search(ip_regex, line)
    if ip_match:
        var1 = ip_match.group(1)

    community_match = re.search(community_regex, line)
    if community_match:
        var2 = community_match.group(1)

# Redirect output to a file
output_file = sys.argv[1].split(".")[0] + "_SNMPd.txt"
with open(output_file, "w") as file:
    sys.stdout = file

    print("Extracted IP address and community:")
    print("IP address:", var1)
    print("Community:", var2)

    # Step 4: Run snmpwalk
    print("Running snmpwalk command...")
    snmpwalk_command = ["snmpwalk", "-v2c", "-c", var2, var1, "1.3.6.1.2.1.25.4.2.1.2"]
    snmpwalk_output = subprocess.check_output(snmpwalk_command).decode()

    print("snmpwalk output:")
    print(snmpwalk_output)
