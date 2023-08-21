#!/bin/bash

# Destination file for results
OUTPUT_FILE=~/Untitled-KnownVuls.txt

# Clearing previous results
> $OUTPUT_FILE

# Check for CVE-2021-4034 vulnerability in pkexec
echo "pkexec CVE-2021-4034 Vulnerability Check:" >> $OUTPUT_FILE
if command -v pkexec >/dev/null && [ "$(stat -c '%a' $(command -v pkexec))" = "4755" ] && [ "$(stat -c '%Y' $(command -v pkexec))" -lt "1642035600" ]; then
    echo "Vulnerable to CVE-2021-4034" >> $OUTPUT_FILE
else
    echo "Not vulnerable to CVE-2021-4034" >> $OUTPUT_FILE
fi
echo -e "\n" >> $OUTPUT_FILE
