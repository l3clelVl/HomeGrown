#!/usr/bin/env bash

# Generate a random password
RANDOM_PASSWORD=$(openssl rand -base64 12 | tr -d '+/=1liILoO08')

# Define directory paths
WEB_HOSTED_PAYLOADS_DIR="/home/kali/Desktop/WorkingFolder/WebHostedPayloads"

# Check if directory exists
if [[ ! -d "$WEB_HOSTED_PAYLOADS_DIR" ]]; then
    echo "The directory $WEB_HOSTED_PAYLOADS_DIR does not exist."
    exit 1
fi

# Check if running as root for binding to port 80
if [[ $EUID -ne 0 ]]; then
    echo "This script wasn't run as root, which is required to bind to port 80."
    read -p "Do you want to continue anyway? (y/n): " CONTINUE
    if [[ $CONTINUE != "y" ]]; then
        exit 1
    fi
fi

# Define the commands to run, using the directory path variables
Web_Host_HTTP="/usr/bin/python3 -m http.server 80 --directory $WEB_HOSTED_PAYLOADS_DIR"
Web_Host_SMB="echo 'Generated SMB Password: $RANDOM_PASSWORD'; /usr/bin/impacket-smbserver platter $WEB_HOSTED_PAYLOADS_DIR -smb2support -username guest -password $RANDOM_PASSWORD"

# Open new Terminator windows to run the commands
terminator -e "$Web_Host_HTTP" &
terminator -e "$Web_Host_SMB" &
