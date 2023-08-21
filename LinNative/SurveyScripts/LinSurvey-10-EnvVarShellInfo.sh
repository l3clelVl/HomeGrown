#!/bin/bash

# Save the results to this file
output_file=~/Untitled-EnvVarShellConfig.txt

# Clear the output file if it exists
> $output_file

# Gather environment variables
echo "#### Environment Variables ####" >> $output_file
printenv >> $output_file
echo -e "\\n\\n" >> $output_file

# Examine ~/.bashrc
echo "#### Content of ~/.bashrc ####" >> $output_file
cat ~/.bashrc >> $output_file
echo -e "\\n\\n" >> $output_file

# Examine ~/.bash_profile
if [[ -f ~/.bash_profile ]]; then
    echo "#### Content of ~/.bash_profile ####" >> $output_file
    cat ~/.bash_profile >> $output_file
    echo -e "\\n\\n" >> $output_file
fi

# Examine ~/.profile
if [[ -f ~/.profile ]]; then
    echo "#### Content of ~/.profile ####" >> $output_file
    cat ~/.profile >> $output_file
    echo -e "\\n\\n" >> $output_file
fi

# Examine ~/.zshrc (for Zsh users)
if [[ -f ~/.zshrc ]]; then
    echo "#### Content of ~/.zshrc ####" >> $output_file
    cat ~/.zshrc >> $output_file
    echo -e "\\n\\n" >> $output_file
fi

echo "Data collection complete. Results saved to $output_file."
