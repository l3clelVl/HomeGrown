#!/bin/bash

###############################################################
# Author: DeMzDaRulez
# Origin: 5Jan24
# CAO: 5Jan24
# Usage: ./3_RunemAll.sh
#
# Improvement opportunity: NatM
#
# Purpose: 
#     Intended to be the final of 3 files working in sequence for practical understanding of the SUID/SGID privileges. It does 2 important thing:
#           1st = Executes all "t-*" files with the options and arguments ' -p -c id; echo -e "\n" '
#           2nd = Highlights the words "root", "mail". "$USER" (the account running the script) for easy distinction in the misconfigurations
#   All three of the files below work in sequence for practical understanding of the SUID/SGID privileges:
#     1_Make-SUID-SGID-Artifacts.sh
#       Location:
#         Using root/sudo privileges, it copies /bin/bash into "test" to be named with 6 specific user/group and chmod permission variations
#             Example name: "t-mail-root-2555.sh" = A file with "-r-xr-sr-x" perms, user "mail" and group "root"
#     2_Find_SGID-SUID-Both.sh
#       Location:
#         Looks in the current directory for SUID and SGID with at least "read" and "execute" perms for the "other" identity.
#             Note: Opportunity to add the ability to use the current user's name as a tertiary check.
#     3_RunemAll.sh
#       Location:
#         This is where every t-*.sh is executed via the current user to show the dangers of SUID and SGID misconfiguration.
#     Lastly, and with immense caution: The binaries are available for a user to enter a shell and investigate themselves, danger and all.
#     
#     Disclaimer: By running this script, you acknowledge and accept full responsibility for any misconfigurations or security risks introduced into your system.
###############################################################



# ANSI escape codes for text colors
RED='\033[0;31m'      # Red
BLUE='\033[0;34m'     # Blue
YELLOW='\033[0;33m'   # Yellow
RESET='\033[0m'       # Reset to default color

# Loop through files starting with "c-"
for file in t-*; do
  if [[ -f $file ]]; then
    echo "File name: $file"
    # Execute the command, grep for "root," and highlight it in red
    output=$(./$file -p -c id; echo -e "\n")


    # Highlight "portfwd" in yellow
    output="${output//root/${RED}root${RESET}}"

    # Highlight "portfwd" in yellow
    output="${output//mail/${YELLOW}mail${RESET}}"
    
    # Highlight "kali" in blue
    output="${output//$USER/${BLUE}$USER${RESET}}"
    
    echo -e "$output\n"
  fi
done
