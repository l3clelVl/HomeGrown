#!/usr/bin/env python3

'''
###############################################################
# Author: DeMzDaRulez
# Origin: 3Jan24
# CAO: 4Jan24
# Usage: python3 CleanupDirectoryCrawl.py input_file output_file
# Future tasks: None. Complete for intent.
# Purpose: Short description: mimic the below awk/sort. 
# 		awk -F/ '/http/ { split($1, a, " "); print a[1] "\t" "/" $4 }' "$1" | sort -u -k2,2 -k1,1 > "$2"
	1) Grab first (status code) and last (URL) columns
	2) Strip from "http" to the end of the domain.tld
	3) Sort each line by the second column, then remove duplicates
	4) Sort each line by the first column
#
# AWK Explanation:
# awk is a text processing tool commonly used in Unix-like operating systems for pattern scanning and text manipulation.
#
# -F/ specifies the field separator as /. This means that awk will split each line of input into fields whenever it encounters a / character.
#
# '/http/ { split($1, a, " "); print a[1] "\t" "/" $4 }' is an awk program enclosed in single quotes.
#
# /http/ is a pattern to match lines containing the text "http".
#
# { and } enclose the action to be taken when the pattern is matched.
#
# split($1, a, " ") splits the first field ($1) using a space as the delimiter and stores the resulting parts in an array a. This is used to separate the status code (e.g., "200") from the HTTP request line.
#
# print a[1] "\t" "/" $4 prints the first element of the a array (the status code), followed by a tab character ("\t"), and then a forward slash ("/") followed by the fourth field ($4). This combination effectively extracts the status code and the URL path from each line.
#
###############################################################
'''

import sys
import re

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 CleanupDirectoryCrawl.py input_file output_file")
        sys.exit(1)

    input_file_name = sys.argv[1]
    output_file_name = sys.argv[2]

    try:
        with open(input_file_name, "r") as input_file:
            lines = input_file.readlines()

        http_data = []

        for line in lines:
            match = re.search(r'(\d+\s+)(GET\s+\d+\w+\s+\d+\w+\s+\d+\w+\s+)(http://[^/]+)(/.*)', line)
            if match:
                http_data.append(match.group(1) + match.group(4))

        # Sort the data by the second column (URL path) and remove duplicates
        http_data = sorted(set(http_data), key=lambda x: x.split()[1])

        # Sort the data by the first column (status code)
        http_data = sorted(http_data, key=lambda x: x.split()[0])

        with open(output_file_name, "w") as output_file:
            for item in http_data:
                output_file.write("%s\n" % item)

        print(f"Output file created at: {output_file_name}")
    except Exception as e:
        print(f"An error occurred: {e}")
