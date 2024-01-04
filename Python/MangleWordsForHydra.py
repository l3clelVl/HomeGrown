#############################################################################
# Author: DeMzDaRulez
# Date: 21Jun23
# CAO: 2Jan24
# usage: python ThisScript.py ListForPasswords.txt
# Purpose:
#  1) User input file of words (probably scraped from a website with CeWL)
#  2) Change all the words into lower, upper, and camel case, so the file can be used for hydra brute force
#############################################################################

# Prompt the user for the input file's absolute path
file_path = input("Enter the absolute path of the input file: ")

# Open and read the file
with open(file_path, "r") as file:
    words = file.read().splitlines()

# Process the words
upper_case_words = [word.upper() for word in words]
lower_case_words = [word.lower() for word in words]
camel_case_words = [word.title() for word in words]

# Prompt the user for the output file's absolute path
output_file_path = input("Enter the absolute path of the output file: ")

# Open the output file for writing
with open(output_file_path, "w") as output_file:
    output_file.write("\n".join(lower_case_words + camel_case_words + upper_case_words) + "\n")

print("Conversion results written to the output file.")
