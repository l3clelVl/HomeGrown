#!/bin/bash
###############################################################
# Author: DeMzDaRulez
# Origin: 5Jan24
# CAO: 5Jan24
# Usage: 
#
# Improvement opportunity: Add the ability to use the current user's name as a tertiary check for the "2_Find_SGID-SUID-Both.sh"
#
# Purpose: This File Creates 6 separate files only when ran inside the "test" folder with root equivalent privileges.
#   All three of the files below work in sequence for practical understanding of the SUID/SGID privileges:
#        Location: https://github.com/l3clelVl/HomeGrown/tree/aa24ea8be358840d336bc5e6deda8d0e345ebd11/Practical-Learning/SUID-SGID-Practical
#     1_Make-SUID-SGID-Artifacts.sh      
#         Using root/sudo privileges, it copies /bin/bash into "test" to be named with 6 specific user/group and chmod permission variations
#             Example name: "t-mail-root-2555.sh" = A file with "-r-xr-sr-x" perms, user "mail" and group "root"
#     2_Find_SGID-SUID-Both.sh
#         Looks in the current directory for SUID and SGID with at least "read" and "execute" perms for the "other" identity.
#             Note: Opportunity to add the ability to use the current user's name as a tertiary check.
#     3_RunemAll.sh
#         This is where every t-*.sh is executed via the current user to show the dangers of SUID and SGID misconfiguration.
#     Lastly, and with immense caution: The binaries are available for a user to enter a shell and investigate themselves, danger and all.
#     
#     Disclaimer: By running this script, you acknowledge and accept full responsibility for any misconfigurations or security risks introduced into your system.
###############################################################
# Check if the script is running with root or sudo privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run with root or sudo privileges, because it will be copying /bin/bash into 6 files with varying permissions."
  exit 1
fi
# Prompt the user to confirm acceptance of responsibility
echo -n "I recommend you use this script and practice on a fresh VM or Docker image, so the risk is essentially zero."
echo -n "Do you have the authority to accept full responsibility for the misconfigurations and security risks this script will introduce into this system, if so, do you accept the risk and release DeMzDaRulez from any damages (yes/no): "
read acceptance
# Check if the user accepted responsibility
if [[ "$acceptance" != "yes" ]]; then
  echo "Thank you for your honesty."
  exit 1
fi
# Check if the script is in a folder named "test"
if [[ $(basename "$(pwd)") != "test" ]]; then
  echo "This script must be run from a folder named 'test'."
  exit 1
fi
# Define the source file path (assuming it's "/bin/sh")
source_file="/bin/sh"
# List of target file names
file_names=(
  "t-mail-root-2555.sh"
  "t-mail-root-4555.sh"
  "t-mail-root-6555.sh"
  "t-root-mail-2555.sh"
  "t-root-mail-4555.sh"
  "t-root-mail-6555.sh"
)
# Loop through the file names and copy/rename the files
for file_name in "${file_names[@]}"; do
  # Check if the source file exists
  if [[ -f "$source_file" ]]; then
    # Copy the source file to the current directory with the target name
    cp "$source_file" "$file_name"
    
    # Extract the parts of the target filename based on hyphens
    IFS='-' read -r -a name_parts <<< "$file_name"
    
    # Check if there are enough parts to process
    if [[ ${#name_parts[@]} -ge 3 ]]; then
      user=${name_parts[1]}
      group=${name_parts[2]}
      
      # Extract the numeric part of the filename without the ".sh" extension
      chmod_val=$(echo "${name_parts[3]}" | sed 's/\.sh//')
      
      # Check if the user and group are valid
      if id "$user" &>/dev/null && id "$group" &>/dev/null; then
          # Set ownership based on the filename
          chown "$user:$group" "$file_name"
          
          # Set permissions based on the numeric part of the filename
          chmod "$chmod_val" "$file_name"
          echo "Copied and renamed file: $source_file to $file_name with permissions $chmod_val"
      else
          echo "Invalid user or group in filename: $file_name"
      fi
    else
      echo "Invalid target filename format: $file_name"
    fi
  else
    echo "Source file not found: $source_file"
  fi
done
# Inform the user about the completion
echo -e "\n\n\nCompleted successfully. Use 'ls -la t-*' command as proof:"
echo -en "Use 'RunemAll.sh' to test your effective permissions"
