#!/bin/bash

# Saving the results to ~/Untitled-NetInfo.txt
output_file=~/Untitled-NetInfo.txt

# Clearing any previous content in the output file
> $output_file

# Gathering Interface Details
echo "### Interface Details ###" >> $output_file
ip a >> $output_file
echo "" >> $output_file

# Listening Ports
echo "### Listening Ports ###" >> $output_file
netstat -tuln >> $output_file
echo "" >> $output_file

# Established Connections
echo "### Established Connections ###" >> $output_file
netstat -tul >> $output_file
echo "" >> $output_file

# Displaying the Routing Table
echo "### Routing Table ###" >> $output_file
route -n >> $output_file
echo "" >> $output_file

# Displaying ARP Cache
echo "### ARP Cache ###" >> $output_file
arp -n >> $output_file
echo "" >> $output_file

# Displaying Firewall Rules
echo "### Firewall Rules ###" >> $output_file
iptables -L -n -v >> $output_file
echo "" >> $output_file

# DNS Information
echo "### DNS Information ###" >> $output_file
cat /etc/resolv.conf >> $output_file
echo "" >> $output_file

# Network Statistics
echo "### Network Statistics ###" >> $output_file
netstat -s >> $output_file
echo "" >> $output_file

# Network Connections by Process
echo "### Network Connections by Process ###" >> $output_file
lsof -i >> $output_file
echo "" >> $output_file

# Socket Statistics
echo "### Socket Statistics ###" >> $output_file
ss -s >> $output_file
echo "" >> $output_file

# Packet Capture (Note: This command is commented out to prevent inadvertent captures. Uncomment for use.)
#echo "### Packet Capture ###" >> $output_file
#tcpdump -i eth0 -c 10 >> $output_file
#echo "" >> $output_file

# Bandwidth Usage (Note: This command is commented out as it requires an interactive terminal. Uncomment for use.)
#echo "### Bandwidth Usage ###" >> $output_file
#iftop -i eth0 -t -s 10 >> $output_file
#echo "" >> $output_file

# Check for Promiscuous Mode
echo "### Check for Promiscuous Mode ###" >> $output_file
ip link show >> $output_file
echo "" >> $output_file

echo "Network information saved to $output_file"
