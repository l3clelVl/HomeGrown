#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Destination directory for the copied history files
destDir="/tmp"  # or use destDir="$HOME" for the home directory of the current user

# Iterate over the home directories in /home
for userHome in /home/*; do
    # Extract username from the path
    userName=$(basename $userHome)
    
    # Check and copy bash history
    if [[ -f "$userHome/.bash_history" ]]; then
        cp "$userHome/.bash_history" "$destDir/${userName}_bash_history"
    fi

    # Check and copy zsh history
    if [[ -f "$userHome/.zsh_history" ]]; then
        cp "$userHome/.zsh_history" "$destDir/${userName}_zsh_history"
    fi

    # Similarly, add checks for other shells' history files if needed
done
