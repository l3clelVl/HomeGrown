##################################################################
# Author: DeMzDaRulez
# CAO: 16Dec23
# Purpose: Iterative permutation (Double-up words)
# Example: 1,23,a,bc into 1,11,123,1a,1bc,23,2323,23a,23bc,a,aa,abc,bc,bcbc
##################################################################

import sys
from itertools import permutations

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
    for word in words:
        newfile.write(word + "\n")

    for word1 in words:
        for word2 in words:
            newfile.write(word1 + word2 + "\n")

print(f"Combinations generated from {input_file} and saved to {output_file}.")

