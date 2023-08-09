#!/bin/bash

# File to save the results
output_file=~/Untitled-OSinfo.txt

# Clearing the output file if it already exists
> $output_file

# Gathering kernel details
echo "### Kernel Details ###" >> $output_file
uname -a >> $output_file
echo "" >> $output_file

# Gathering OS release information
echo "### OS Release Information ###" >> $output_file
cat /etc/os-release >> $output_file
echo "" >> $output_file

# Gathering OS distribution information
echo "### OS Distribution Information ###" >> $output_file
if [ -f /etc/lsb-release ]; then
    cat /etc/lsb-release >> $output_file
elif [ -f /etc/redhat-release ]; then
    cat /etc/redhat-release >> $output_file
elif [ -f /etc/debian_version ]; then
    echo "Debian version:" && cat /etc/debian_version >> $output_file
fi
echo "" >> $output_file

# Gathering information from /etc/issue
echo "### /etc/issue Content ###" >> $output_file
cat /etc/issue >> $output_file
echo "" >> $output_file

# Gathering current runlevel
echo "### Current Runlevel ###" >> $output_file
runlevel >> $output_file
echo "" >> $output_file

# Gathering uptime information, showing how long the system has been running
echo "### Uptime Information ###" >> $output_file
uptime >> $output_file
echo "" >> $output_file

# Informing the user
echo "Information gathered and saved to $output_file"
