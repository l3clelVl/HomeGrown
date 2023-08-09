#!/bin/bash

# File to store results
OUTPUT_FILE=~/Untitled-Logs.txt

# Clear previous results
> $OUTPUT_FILE

# Function to append output to the result file
save_to_file() {
    echo -e "\\n[+] $1" >> $OUTPUT_FILE
    echo "---------------------------------------------" >> $OUTPUT_FILE
    cat $2 >> $OUTPUT_FILE
    echo -e "\\n" >> $OUTPUT_FILE
}

# Gather authentication logs
save_to_file "Authentication Logs" /var/log/auth.log

# Gather system events
save_to_file "Syslog" /var/log/syslog

# Gather kernel logs
save_to_file "Kernel Logs" /var/log/kern.log

# Gather boot logs
save_to_file "Boot Logs" /var/log/boot.log

# Gather package manager logs (assuming apt for Debian/Ubuntu systems)
save_to_file "DPKG Logs" /var/log/dpkg.log
save_to_file "APT Logs" /var/log/apt/history.log

# Check for application-specific logs
for log in /var/log/*.log; do
    save_to_file "$(basename $log) Logs" $log
done

# End of script
echo "Logs have been saved to $OUTPUT_FILE"
