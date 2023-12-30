#!/usr/bin/env python

###############################################################
# Author: DeMzDaRulez
# Updated: 29Dec23
# Usage: python DissectCreds.py input_file
# Purpose: Create 4 files from a creds file using a colon as a delimiter.
#          Perform a sort and remove duplicates. Handle various cases where
#          fields may be empty or contain spaces.
# Content format: username:password:hash (fields can be empty)
#
# 29Dec23 Update = The regex pattern has been adjusted to:
# ^\s*(.*?)(?=\s*:) captures any characters at the start of the line until the first colon
# 	-> Intended for leading spaces and an empty field.
# (?<=:)\s*(.*?)(?=\s*:) captures any characters between two colons
# 	-> Intended for spaces and an empty field.
# (?<=:)\s*(.*?)\s*$ captures any characters after the last colon until the end of the line
# 	-> Intended for trailing spaces and an empty field.
###############################################################

#!/usr/bin/env python

import re
import sys

def write_to_file(content, filename, suffix):
    with open(f"{filename}{suffix}", 'w') as file:
        file.write('\n'.join(sorted(set(content), key=str.lower)) + '\n')

if len(sys.argv) != 2:
    print("Usage: python DissectCreds.py input_file")
    sys.exit(1)

input_file = sys.argv[1]

try:
    with open(input_file, 'r') as file:
        lines = file.readlines()
except FileNotFoundError:
    print(f"Error: The file '{input_file}' does not exist.")
    sys.exit(1)

pattern = r'^\s*(.*?)\s*:\s*(.*?)\s*:\s*(.*?)\s*$'
matches = [re.match(pattern, line) for line in lines]

usernames, passwords, hashes = [], [], []
for match in matches:
    if match:
        uname, pword, hsh = match.groups()
        usernames.append(uname)
        passwords.append(pword)
        hashes.append(hsh)

base_filename = input_file.rsplit('.', 1)[0]
write_to_file(usernames, base_filename, '_Usernames.txt')
write_to_file(passwords, base_filename, '_Passwords.txt')
write_to_file(hashes, base_filename, '_Hashes.txt')

all_content = usernames + passwords + hashes
write_to_file(all_content, base_filename, '_Triumvirate.txt')

print("Dissection completed successfully.")
