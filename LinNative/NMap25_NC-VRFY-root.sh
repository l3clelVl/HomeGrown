##################################################
#
# This is version 2.3
#
##################################################
#!/bin/bash
: << 'VER_2.3_COMMENTS'
# Check if both script arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: ./smtp_verification.sh <ip_list_file> <output_file>"
  exit 1
fi

# Check if 'bc' command is available
if ! command -v bc >/dev/null 2>&1; then
  echo "Error: 'bc' command not found. Please install 'bc' before running this script."
  exit 1
fi

# Assign script arguments to variables
ip_list_file=$1
output_file=$2

# Get the total number of lines in the IP list file
total_lines=$(wc -l < "$ip_list_file")
current_line=0

# Iterate over each IP in the list
while IFS= read -r ip; do
  # Increment the current line counter
  ((current_line++))

  # Use nmap to check if SMTP port (25) is open
  nmap_result=$(nmap -p 25 --open "$ip" | grep -E '25/tcp\s+open')

  # If the SMTP port is open, use nc to connect and send the VRFY command
  if [ -n "$nmap_result" ]; then
    nc_result=$(echo "VRFY root" | nc "$ip" 25)

    # Append the IP and the response code to the output file
    echo "$ip: $nc_result" >> "$output_file"
  fi

  # Calculate the percentage completion
  percentage=$(bc <<< "scale=2; ($current_line/$total_lines) * 100")

  # Print progress update
  echo -ne "Progress: $percentage% \r"
done < "$ip_list_file"

# Print completion message
echo "100% complete"
VER_2.3_COMMENTS


#!/bin/bash

# Check if both script arguments are provided
if [[ $# -ne 2 ]]; then
  echo "Usage: ./smtp_verification.sh <ip_list_file> <output_file>"
  exit 1
fi

# Check if 'bc' command is available
if ! command -v bc >/dev/null 2>&1; then
  echo "Error: 'bc' command not found. Please install 'bc' before running this script."
  exit 1
fi

# Assign script arguments to variables
ip_list_file=$1
output_file=$2

# Get the total number of lines in the IP list file
total_lines=$(wc -l < "$ip_list_file")
current_line=0

# Iterate over each IP in the list
while IFS= read -r ip; do
  # Increment the current line counter
  ((current_line++))

  # Use nmap to check if SMTP port (25) is open
  nmap_result=$(nmap -p 25 --open "$ip" | grep -E '25/tcp\s+open')

  # If the SMTP port is open, use nc to connect and send the VRFY command
  if [[ -n "$nmap_result" ]]; then
    nc_result=$(echo "VRFY root" | nc "$ip" 25)

    # Append the IP and the response code to the output file
    echo "$ip: $nc_result" >> "$output_file"
  fi

  # Calculate the percentage completion
  percentage=$(bc <<< "scale=2; ($current_line/$total_lines) * 100")

  # Update the progress bar
  echo "$percentage% complete" | pv -qL 10
done < "$ip_list_file"

# Print completion message
echo "100% complete"









: << 'VER_1_COMMENTS'
'''
#!/bin/bash

# Check if both script arguments are provided
if [[ $# -ne 2 ]]; then
  echo "Usage: ./smtp_verification.sh <ip_list_file> <output_file>"
  exit 1
fi

# Assign script arguments to variables
ip_list_file=$1
output_file=$2

# Iterate over each IP in the list
while IFS= read -r ip; do
  # Use nmap to check if SMTP port (25) is open
  nmap_result=$(nmap -p 25 --open "$ip" | grep -E '25/tcp\s+open')

  # If the SMTP port is open, use nc to connect and send the VRFY command
  if [[ -n "$nmap_result" ]]; then
    nc_result=$(echo "VRFY root" | nc "$ip" 25)

    # Append the IP and the response code to the output file
    echo "$ip: $nc_result" >> "$output_file"
  fi
done < "$ip_list_file"
VER_1_COMMENTS
