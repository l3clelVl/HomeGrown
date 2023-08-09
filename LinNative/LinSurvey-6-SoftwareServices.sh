#!/bin/bash

# File to store the results
output_file=~/Untitled-SoftwareServices.txt

# Clear previous data in the file
> $output_file

# Check for installed software using dpkg (commonly used in Debian-based systems)
echo "## Installed software via dpkg:" >> $output_file
dpkg -l >> $output_file
echo "\n\n" >> $output_file

# Check for installed software using rpm (commonly used in RedHat-based systems)
echo "## Installed software via rpm:" >> $output_file
rpm -qa >> $output_file
echo "\n\n" >> $output_file

# Check for installed software using yum (older RedHat-based systems)
echo "## Installed software via yum:" >> $output_file
yum list installed >> $output_file 2>/dev/null
echo "\n\n" >> $output_file

# Check for installed software using dnf (newer RedHat-based systems)
echo "## Installed software via dnf:" >> $output_file
dnf list installed >> $output_file 2>/dev/null
echo "\n\n" >> $output_file

# List running services using systemctl (modern Linux systems with systemd)
echo "## Running services via systemctl:" >> $output_file
systemctl list-units --type=service --state=running >> $output_file
echo "\n\n" >> $output_file

# List running services using service (older systems without systemd)
echo "## Running services via service:" >> $output_file
service --status-all >> $output_file 2>/dev/null
echo "\n\n" >> $output_file

echo "Data collection complete. Results saved in $output_file."
