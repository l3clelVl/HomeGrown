#!/usr/bin/env bash

#######################################################################################################################
# 
# This script is intended to spawn individual terminator windows for web hosting services and to track their traffic.
# Currently, it spawns the services below with their own window
# 1) HTTP
# 2) SMB 
#
# Future goals: Output for the traffic from those services will also populate in the spawner term and log files
# # Currently, the HTTP window populates with traffic, but that same population doesn't happen in the log or the OG term
#######################################################################################################################


# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if running as root for binding to port 80
if [[ $EUID -ne 0 ]]; then
  echo "This script wasn't run as root, which is required to bind to port 80."
  read -p "Do you want to continue anyway? (y/n): " CONTINUE
  if [[ ${CONTINUE,,} != "y" ]]; then
    exit 1
  else
    USERNAME=$USER  # Use $USER if proceeding without sudo
  fi
else
  USERNAME=$SUDO_USER  # Use $SUDO_USER if script is run with sudo
fi

# Check for required software
for cmd in "python3" "impacket-smbserver" "terminator"; do
  if ! command_exists $cmd; then
    echo "Error: $cmd is not installed."
    exit 1
  fi
done

# Generate a random password
RANDOM_PASSWORD=$(openssl rand -base64 12 | tr -d '+/=1liILoO08')

# Define directory paths
WEB_HOSTED_PAYLOADS_DIR="/home/kali/Desktop/WorkingFolder/WebHostedPayloads"

# Check if directory exists
if [[ ! -d "$WEB_HOSTED_PAYLOADS_DIR" ]]; then
  echo "The directory $WEB_HOSTED_PAYLOADS_DIR does not exist."
  exit 1
fi

# Generate filenames with timestamps and protocols
TIME_STAMP=$(date +"%Y-%m-%d_%H-%M-%S")
HTTP_LOG="/home/$USERNAME/Desktop/HTTP_${TIME_STAMP}.log"
SMB_LOG="/home/$USERNAME/Desktop/SMB_${TIME_STAMP}.log"

# Create the log files, ensuring they're owned by the user
touch $HTTP_LOG $SMB_LOG
chown $USERNAME:$USERNAME $HTTP_LOG $SMB_LOG

# Define the commands to run, using the directory path variables
Web_Host_HTTP="/usr/bin/python3 -u -m http.server 80 --directory $WEB_HOSTED_PAYLOADS_DIR | tee $HTTP_LOG"
Web_Host_SMB="echo 'Generated SMB Password: $RANDOM_PASSWORD'; /usr/bin/impacket-smbserver platter $WEB_HOSTED_PAYLOADS_DIR -smb2support -username guest -password $RANDOM_PASSWORD | tee $SMB_LOG"

# Open new Terminator windows to run the commands
terminator -e "$Web_Host_HTTP" &
terminator -e "$Web_Host_SMB" &

# Tail the log files to display output in the original terminal
tail -f $SMB_LOG $HTTP_LOG &