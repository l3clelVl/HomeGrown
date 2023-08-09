#!/bin/bash

# Filename for storing the results
OUTPUT_FILE=~/Untitled-FileSysInfo.txt

# Clearing previous data in the file
> $OUTPUT_FILE

# Append current date and time to the output file
echo "Filesystem Information as of $(date)" >> $OUTPUT_FILE
echo "==========================================" >> $OUTPUT_FILE

# List all mounted filesystems
echo -e "\\n[Listing all mounted filesystems]" >> $OUTPUT_FILE
mount >> $OUTPUT_FILE

# Display disk space usage for all filesystems
echo -e "\\n[Disk space usage for all filesystems]" >> $OUTPUT_FILE
df -h >> $OUTPUT_FILE

# Display inodes usage for all filesystems
echo -e "\\n[Inodes usage for all filesystems]" >> $OUTPUT_FILE
df -i >> $OUTPUT_FILE

# List all block devices in a tree-like format
echo -e "\\n[Block devices in tree-like format]" >> $OUTPUT_FILE
lsblk >> $OUTPUT_FILE

# Display UUIDs of all partitions
echo -e "\\n[UUIDs of all partitions]" >> $OUTPUT_FILE
blkid >> $OUTPUT_FILE

# Display filesystem statistics
echo -e "\\n[Filesystem statistics]" >> $OUTPUT_FILE
stat -f / >> $OUTPUT_FILE

# End of script
echo -e "\\nEnd of Filesystem Information" >> $OUTPUT_FILE
