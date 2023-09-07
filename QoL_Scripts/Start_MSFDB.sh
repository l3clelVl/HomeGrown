#!/bin/bash
set -e

################################################################################
#
# This script starts services and creates folders necessary for msfconsole and 
# finishes by launching msfconsole and move the error.log to your desktop
#
################################################################################

# Create log file and Redirect output to log file for debugging and monitoring
LOG_FILE="/tmp/Start_MSFDB-Error.log"
touch $LOG_FILE
exec &>> $LOG_FILE

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root to manage system services."
   exit 1
fi

# Parameterized service and console names for easier management
PGSQL_SERVICE="postgresql"
MSF_CONSOLE="msfconsole"

# Enable PostgreSQL service
echo "Enabling ${PGSQL_SERVICE}..."
systemctl enable ${PGSQL_SERVICE}

# Start PostgreSQL service
echo "Starting ${PGSQL_SERVICE}..."
systemctl start ${PGSQL_SERVICE}

# Sleep to allow PostgreSQL to initialize
echo "Sleeping for 3 seconds to allow ${PGSQL_SERVICE} to initialize..."
sleep 3  # Consider replacing with a loop to check service status

# Check PostgreSQL service status
echo "Checking ${PGSQL_SERVICE} status..."
systemctl is-active --quiet ${PGSQL_SERVICE}

# Create Metasploit directories if they don't exist
echo "Creating Metasploit directories..."
[[ -d ~/.msf4/modules ]] || mkdir -p ~/.msf4/modules/{auxiliary,exploits,post}

# Initialize Metasploit database
echo "Initializing Metasploit database..."
msfdb init

# Launch msfconsole as the original user
echo "Launching ${MSF_CONSOLE} as original user..."
terminator -e "sudo -u $SUDO_USER msfconsole" &

# Get the Process ID of the msfconsole job
MSF_PID=$!

# Change ownership and move log file to user's Desktop
chown $SUDO_USER:$SUDO_USER $LOG_FILE
mv $LOG_FILE /home/$SUDO_USER/Desktop/

# Bring msfconsole back to the foreground
kill -s SIGCONT $MSF_PID