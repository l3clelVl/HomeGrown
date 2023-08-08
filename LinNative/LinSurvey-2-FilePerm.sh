#!/bin/bash

# Destination file for results
OUTPUT_FILE=~/Untitled-FilePerm.txt

# Clearing previous results
> $OUTPUT_FILE

# Finding World-Writable Files
echo "World-Writable Files:" >> $OUTPUT_FILE
find / -type f -perm -o=w -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding World-Readable Files
echo "World-Readable Files:" >> $OUTPUT_FILE
find / -type f -perm -o=r -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding World-Executable Files
echo "World-Executable Files:" >> $OUTPUT_FILE
find / -type f -perm -o=x -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding World-Writable Directories
echo "World-Writable Directories:" >> $OUTPUT_FILE
find / -type d -perm -o=w -exec ls -ld {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding SetUID Files
echo "SetUID Files:" >> $OUTPUT_FILE
find / -type f -perm -4000 -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding SetGID Files
echo "SetGID Files:" >> $OUTPUT_FILE
find / -type f -perm -2000 -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding No Owner Files
echo "No Owner Files:" >> $OUTPUT_FILE
find / -nouser -o -nogroup -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding Dot Files
echo "Dot Files in User Directories:" >> $OUTPUT_FILE
find /home -name ".*" -type f -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding Misconfigured Configuration Files
echo "Configuration Files:" >> $OUTPUT_FILE
find /etc/ -type f -perm -o=w -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Checking Log File Permissions
echo "Log Files:" >> $OUTPUT_FILE
find /var/log/ -type f -perm -o=w -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding Backup Files
echo "Backup Files:" >> $OUTPUT_FILE
find / -name "*~" -o -name "*.bak" -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

echo "File Permission Check Completed!"
