#!/bin/bash

# Destination file for results
OUTPUT_FILE=~/Untitled-FilePerm.txt

# Clearing previous results
> $OUTPUT_FILE

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
echo "Misconfig Files:" >> $OUTPUT_FILE
find /etc/ -type f -perm -o=w -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Checking Log File Permissions
echo "Log Files:" >> $OUTPUT_FILE
find /var/log/ -type f -perm -o=w -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE

# Finding Backup Files
echo "Backup Files:" >> $OUTPUT_FILE
find / \( -name "*~" -o -name "*.{bak,tar,gz,bz2,xz,zip,7z,dump,iso,rsync,dar,cpio,bkp}" \) -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n" >> $OUTPUT_FILE


# Pruned search to find NOT /tmp,/proc,/sys World-Writable Directories
echo "NOT /tmp,/proc,/sys World-Writable Directories:" >> $OUTPUT_FILE
find / -type f ! -path "/tmp/*" ! -path "/proc/*" ! -path "/sys/*" -perm -o=w -exec ls -l {} \; 2>/dev/null
echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE


# Finding World-Writable Directories
echo "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Writable Directories:" >> $OUTPUT_FILE
find / -type d -perm -o=w -exec ls -ld {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

# Finding World-Executable Files
echo "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Executable Files:" >> $OUTPUT_FILE
find / -type f -perm -o=x -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

# Finding World-Writable Files
echo "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Writable Files:" >> $OUTPUT_FILE
find / -type f -perm -o=w -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

# Finding World-Readable Files
echo "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Readable Files:" >> $OUTPUT_FILE
find / -type f -perm -o=r -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

echo "File Permission Check Completed!"
