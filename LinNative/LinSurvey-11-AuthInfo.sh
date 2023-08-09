#!/bin/bash

# Saving results to ~/Untitled-AuthInfo.txt
output_file=~/Untitled-AuthInfo.txt

# Clearing previous data in the file
> $output_file

# Check PAM (Pluggable Authentication Modules) configuration
echo "===== PAM Configuration =====" >> $output_file
for pam_config in /etc/pam.d/*; do
    echo "=== $pam_config ===" >> $output_file
    cat $pam_config >> $output_file
    echo -e "\\n" >> $output_file
done

# Examine SSH configurations
echo "===== SSH Configuration =====" >> $output_file
if [ -f /etc/ssh/sshd_config ]; then
    cat /etc/ssh/sshd_config >> $output_file
else
    echo "/etc/ssh/sshd_config not found" >> $output_file
fi
echo -e "\\n" >> $output_file

# Check for other authentication configurations (Optional checks can be added as needed)

# End of script
echo "Data saved to $output_file"
