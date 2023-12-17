##################################################################
# Author: DeMzDaRulez
# Purpose: Iterative hashcat's "d" rule mutator does without breaking
##################################################################

import sys

if len(sys.argv) != 3:
    print("Usage: python generate_combinations.py <input_file> <output_file>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

# Create a list of words from the input file
with open(input_file, "r") as file:
    words = file.read().split()

# Create a new file for the combinations
with open(output_file, "w") as newfile:
    for word1 in words:
        for word2 in words:
            # Avoid combining a word with itself
            if word1 != word2:
                newfile.write(word1 + word2 + "\n")

print(f"Combinations generated from {input_file} and saved to {output_file}.")
