#!/bin/bash

###############################################################
# Author: DeMzDaRulez
# Origin: 5Jan24
# CAO: 5Jan24
# Usage: ./2_Find_SGID-SUID-Both.sh
#
# Improvement opportunity: 
#     1) Add target location option. 
#     2) Add recusive option
#
# Purpose: Preface echo of command intent, then runs command, then 5 line breaks after the completion of each command.
#     Intended to be 2nd of 3 files working in sequence for practical understanding of the SUID/SGID privileges:
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



# Function to run a command and print its purpose
run_command() {
  echo "$1"
  echo "Command: $2"
  echo "Looking..."
  eval "$2"
  echo -e "Those are all I found.\n\n\n\n\n"
}

# Run commands for each case
run_command "Files' group 'root' with SGID (2) and at least read and execute for 'others', resulting in 'egid' and 'groups' for root(0)." \
  "find . -type f -group root -perm -g+s,o+rx"

run_command "Files' group 'root' both SUID and SGID (6) and at least read and execute for 'others', resulting in 'egid' and 'groups' for root(0)." \
  "find . -type f -group root -perm -g+s,u+s,o+rx"

run_command "Files' owner 'root' with SUID (4) and at least read and execute for 'others', resulting in 'euid' for root(0)." \
  "find . -type f -user root -perm -u+s,o+rx"

run_command "Files' owner 'root' with both SUID and SGID (6) and at least read and execute for 'others', resulting in 'euid' for root(0)." \
  "find . -type f -user root -perm -u+s,g+s,o+rx"
