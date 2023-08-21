#!/bin/bash

# File to save the results
OUTPUT_FILE=~/Untitled-SudoInfo.txt

# Clearing previous content of the file, if any
> $OUTPUT_FILE

# Check what commands the current user can execute as sudo
echo "===== sudo -l =====" >> $OUTPUT_FILE
sudo -l >> $OUTPUT_FILE 2>&1
echo "" >> $OUTPUT_FILE

# List all users and their sudo abilities
echo "===== Checking sudo abilities for all users =====" >> $OUTPUT_FILE
for user in $(getent passwd | cut -f1 -d:); do
    echo "User: $user" >> $OUTPUT_FILE
    sudo -l -U $user >> $OUTPUT_FILE 2>&1
    echo "" >> $OUTPUT_FILE
done

# Check for NOPASSWD entries in sudoers file. This indicates commands that can be run without a password.
echo "===== Checking for NOPASSWD entries in sudoers =====" >> $OUTPUT_FILE
sudo grep -i NOPASSWD /etc/sudoers >> $OUTPUT_FILE 2>&1
sudo grep -i NOPASSWD /etc/sudoers.d/* >> $OUTPUT_FILE 2>&1
echo "" >> $OUTPUT_FILE

# List aliases from sudoers
echo "===== Checking for command aliases in sudoers =====" >> $OUTPUT_FILE
sudo grep -i 'Cmnd_Alias' /etc/sudoers >> $OUTPUT_FILE 2>&1
sudo grep -i 'Cmnd_Alias' /etc/sudoers.d/* >> $OUTPUT_FILE 2>&1
echo "" >> $OUTPUT_FILE

# Periodically save the results after each command
sync

echo "Data saved to $OUTPUT_FILE"
