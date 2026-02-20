# ##########################
# https://github.com/l3clelVl/HomeGrown/blob/main/Python/161SNMP.py
# Author: DeMzDaRulez
# OG = 29Jul23
# v4 = 16Feb26
# Purpose: Lightweight wrapper to run onesixtyone then perform an snmpwalk
# Actions: 1) Create a temporary community list file `community.tmp`, 2) run
#          `onesixtyone` against the provided target using that wordlist,
#          3) parse the onesixtyone output for an IP and community string,
#          4) run `snmpwalk` against the discovered community and save results
#             to a file named <target-prefix>_SNMPd.txt.
# Usage: python3 161SNMP.py <target-ip>
# Notes: This script assumes `onesixtyone` and `snmpwalk` are installed and
#        available on PATH. It writes `community.tmp` in the current working
#        directory and will overwrite existing files with the same name.
# ##########################
#!/usr/bin/env python3

import subprocess
import re
import sys
import os

# Version: 3.4

if len(sys.argv) != 2:
    print("Usage: python3 161SNMP.py <target-ip>")
    sys.exit(1)

target = sys.argv[1]

# Step 1: Determine wordlist to feed into onesixtyone
wordlist_path = "/usr/share/seclists/Discovery/SNMP/snmp-onesixtyone.txt"
if os.path.exists(wordlist_path):
    # Use the seclists file directly
    onesixtyone_wordlist = wordlist_path
else:
    # Create community.tmp from a small fallback list and use that
    community_strings = ["public", "private", "manager"]
    with open("community.tmp", "w") as fh:
        fh.write("\n".join(community_strings))
    onesixtyone_wordlist = "community.tmp"

# Step 2: Run onesixtyone with community.tmp file
onesixtyone_command = ["onesixtyone", "-i", target, "-c", onesixtyone_wordlist]
try:
    onesixtyone_output = subprocess.check_output(onesixtyone_command, stderr=subprocess.DEVNULL).decode().splitlines()
except FileNotFoundError:
    print("Error: onesixtyone not found on PATH")
    sys.exit(2)
except subprocess.CalledProcessError:
    onesixtyone_output = []

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

# If onesixtyone produced nothing useful, default to target and 'public'
if not var1:
    var1 = target
if not var2:
    var2 = "public"

# Redirect output to a file
output_file = target.split(".")[0] + "_SNMPd.txt"
with open(output_file, "w") as fh:
    print("Extracted IP address and community:", file=fh)
    print("IP address:", var1, file=fh)
    print("Community:", var2, file=fh)

    # Step 4: Run snmpwalk
    print("Running snmpwalk command...", file=fh)
    snmpwalk_command = ["snmpwalk", "-v2c", "-c", var2, var1, "1.3.6.1.2.1.25.4.2.1.2"]
    try:
        snmpwalk_output = subprocess.check_output(snmpwalk_command, stderr=subprocess.DEVNULL).decode()
    except FileNotFoundError:
        print("Error: snmpwalk not found on PATH", file=fh)
        snmpwalk_output = ""
    except subprocess.CalledProcessError:
        snmpwalk_output = ""

    print("snmpwalk output:", file=fh)
    print(snmpwalk_output, file=fh)
