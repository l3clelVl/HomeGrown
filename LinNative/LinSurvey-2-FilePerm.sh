#!/bin/bash

# Destination file for results
OUTPUT_FILE=~/Untitled-FilePerm.txt

# Clearing previous results
> $OUTPUT_FILE

# Finding SetUID Capable Files
printf "SetUID Capable Files:\n" >> $OUTPUT_FILE
$(find / -type f -iname getcap 2>/dev/null) -r / 2>/dev/null >> $OUTPUT_FILE
printf "\n" >> $OUTPUT_FILE

# Finding SetUID Files
printf "SetUID Files:\n" >> $OUTPUT_FILE
find / -type f -perm -4000 -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n" >> $OUTPUT_FILE

# Finding SetGID Files
printf "SetGID Files:\n" >> $OUTPUT_FILE
find / -type f -perm -2000 -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n" >> $OUTPUT_FILE

# Finding No Owner Files
printf "No Owner Files:\n" >> $OUTPUT_FILE
find / -nouser -o -nogroup -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n" >> $OUTPUT_FILE

# Finding Dot Files
printf "Dot Files in User Directories:\n" >> $OUTPUT_FILE
find /home -name ".*" -type f -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n" >> $OUTPUT_FILE

# Finding Misconfigured Configuration Files
printf "Misconfig Files:\n" >> $OUTPUT_FILE
find /etc/ -type f -perm -o=w -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n" >> $OUTPUT_FILE

# Checking Log File Permissions
printf "Log Files:\n" >> $OUTPUT_FILE
find /var/log/ -type f -perm -o=w -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n" >> $OUTPUT_FILE

# Finding Backup Files
printf "Backup Files:\n" >> $OUTPUT_FILE
find / \( -name "*~" -o -iname "*.{bak,tar,gz,bz2,xz,zip,7z,dump,iso,rsync,dar,cpio,bkp}" \) -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n" >> $OUTPUT_FILE


# Pruned search to find NOT /tmp,/proc,/sys World-Writable Directories
printf "NOT /tmp,/proc,/sys World-Writable Directories:\n" >> $OUTPUT_FILE
find / -type f ! -path "/tmp/*" ! -path "/proc/*" ! -path "/sys/*" -perm -o=w -exec ls -l {} \; 2>/dev/null
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

# Finding World-Executable Files NOT in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Executable Files NOT in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/:\n" >> $OUTPUT_FILE
find / -type f -perm -o=x -exec ls -l {} \; 2>/dev/null | grep -i -vE '/proc/|/sys/|/usr/share/|/lib/|/usr/bin/|/usr/sbin/|/var/cache/' >> $OUTPUT_FILE
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

# Finding World-Writable Files NOT in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Writeable Files NOT in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/:\n" >> $OUTPUT_FILE
find / -type f -perm -o=w -exec ls -l {} \; 2>/dev/null | grep -i -vE '/proc/|/sys/|/usr/share/|/lib/|/usr/bin/|/usr/sbin/|/var/cache/' >> $OUTPUT_FILE
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

# Finding World-Readable Files NOT in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Readable Files NOT in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/:\n" >> $OUTPUT_FILE
find / -type f -perm -o=r -exec ls -l {} \; 2>/dev/null | grep -i -vE '/proc/|/sys/|/usr/share/|/lib/|/usr/bin/|/usr/sbin/|/var/cache/' >> $OUTPUT_FILE
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE




printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\The missing results in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/ Executable, Writable, Readable Directories, then Files output further down" >> $OUTPUT_FILE
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\The missing results in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/ Executable, Writable, Readable Directories, then Files output:\n" >> $OUTPUT_FILE


# Finding World-Writable Directories
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Writable Directories in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/ :\n" >> $OUTPUT_FILE
find / -type d -perm -o=w -exec ls -ld {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

# Finding World-Executable Files
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Executable Files in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/ :\n" >> $OUTPUT_FILE
find / -type f -perm -o=x -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

# Finding World-Writable Files
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Writable Files in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/ :\n" >> $OUTPUT_FILE
find / -type f -perm -o=w -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

# Finding ALL World-Readable Files
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nWorld-Readable Files in /proc/ /sys/ /usr/share/ /lib/ /usr/bin/ /usr/sbin/ /var/cache/ :\n" >> $OUTPUT_FILE
find / -type f -perm -o=r -exec ls -l {} \; 2>/dev/null >> $OUTPUT_FILE
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> $OUTPUT_FILE

printf "File Permission Check Completed!"
