#!/bin/bash

# Define directory paths
WEB_HOSTED_PAYLOADS_DIR="/home/kali/Desktop/WorkingFolder/WebHostedPayloads"

# Check if running as root for binding to port 80
if [[ $EUID -ne 0 ]]; then
    echo "This script wasn't ran as root to bind to port 80."
fi

# Define the commands to run, using the directory path variables
Web_Host_HTTP="python3 -m http.server 80 --directory $WEB_HOSTED_PAYLOADS_DIR"
Web_Host_SMB="impacket-smbserver platter $WEB_HOSTED_PAYLOADS_DIR -smb2support -username guest -password smb1forme"

# Open new Terminator windows to run the commands
terminator -e "$Web_Host_HTTP" &
terminator -e "$Web_Host_SMB" &
