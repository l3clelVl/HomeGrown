#!/bin/bash

# Saving results to ~/Untitled-Processes.txt
output_file=~/Untitled-Processes.txt

# Clearing the output file before adding new data
> $output_file

# Get a snapshot of the current processes
echo "==== Current Running Processes (ps aux) ====" >> $output_file
ps aux >> $output_file
echo -e "\n\n" >> $output_file

# Display a tree of processes
echo "==== Process Tree (pstree) ====" >> $output_file
pstree >> $output_file
echo -e "\n\n" >> $output_file

# Display processes in real-time
echo "==== Top Processes (top -n 1) ====" >> $output_file
top -n 1 -b >> $output_file
echo -e "\n\n" >> $output_file

# Check for processes listening on sockets
echo "==== Listening Processes (netstat -tuln) ====" >> $output_file
netstat -tuln >> $output_file
echo -e "\n\n" >> $output_file

# Check for processes listening on sockets using ss
echo "==== Listening Processes (ss -tuln) ====" >> $output_file
ss -tuln >> $output_file
echo -e "\n\n" >> $output_file

# Display open files by processes
echo "==== Open Files by Processes (lsof) ====" >> $output_file
lsof >> $output_file
echo -e "\n\n" >> $output_file

echo "Process information gathered and saved to $output_file"
