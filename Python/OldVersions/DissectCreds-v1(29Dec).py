#!/usr/bin/env python

###############################################################
# Author = DeMzDaRulez
# CAOv5 = 26Dec23
# Usage = python DissectCreds.py input_file
# Purpose = Create 4 files from my creds file using colon as a delimiter. Obligatory sort and unique.
# Content format = username:password:hash
#
###############################################################



import re
import sys

# Function to write content to a file with a specific suffix
def write_to_file(content, filename, suffix):
    with open(filename + suffix, 'w') as file:
        # Sort and remove duplicates before writing to the file
        unique_sorted_content = '\n'.join(sorted(set(content.split('\n'))))
        file.write(unique_sorted_content)

# Check if the script was provided with a command-line argument
if len(sys.argv) != 2:
    print("Usage: python BreakoutCreds.py input_file")
    sys.exit(1)

input_file = sys.argv[1]

# Read the input file
try:
    with open(input_file, 'r') as file:
        content = file.read()
except FileNotFoundError:
    print(f"Error: The file '{input_file}' does not exist.")
    sys.exit(1)

# Use regular expressions to extract username:password:hash lines
matches = re.findall(r'(\w+?):(.*?):(.*?)(?=\n|$)', content, re.DOTALL)

# Create separate lists for usernames, passwords, and hashes
usernames, passwords, hashes = zip(*matches)

# Write usernames, passwords, and hashes to their respective files
write_to_file('\n'.join(usernames), input_file.rstrip('.txt'), '_Usernames.txt')
write_to_file('\n'.join(passwords), input_file.rstrip('.txt'), '_Passwords.txt')
write_to_file('\n'.join(hashes), input_file.rstrip('.txt'), '_Hashes.txt')

# Aggregate all three files and write to a new file with the suffix "All3"
all_content = '\n'.join(usernames + passwords + hashes)
write_to_file(all_content, input_file.rstrip('.txt'), '_Triumvirate.txt')

print("Dissection completed successfully.")
