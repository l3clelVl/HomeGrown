#!/bin/bash

# Saving the results to ~/Untitled-SchTasks.txt
output_file=~/Untitled-SchTasks.txt

# Clearing the output file before appending new data
> $output_file

# Checking system-wide crontab
echo "===== System-wide Crontab =====" >> $output_file
printf "\n\n" >> $output_file
cat /etc/crontab >> $output_file
printf "\n\n\n\n\n\n\n\n\n\n" >> $output_file

# Checking cron jobs in /etc/cron.d/
echo "===== /etc/cron.d/ Jobs =====" >> $output_file
printf "\n\n" >> $output_file
for job_file in /etc/cron.d/*; do
    echo "------------------------------ $job_file ------------------------------" >> $output_file
    cat $job_file >> $output_file
    printf "\n\n\n\n\n" >> $output_file
done
printf "\n\n\n\n\n\n\n\n\n\n" >> $output_file

# Checking every extension to the cron directory
for dir in /etc/cron.*; do
    # Check if it's a directory
    if [[ -d $dir ]]; then
        echo "===== Jobs in $dir =====" >> $output_file
        printf "\n\n" >> $output_file
        for file in "$dir"/*; do
            # Check if it's a regular file and not named .placeholder
            if [[ -f $file && $(basename $file) != ".placeholder" ]]; then
                echo "------------------------------ $file ------------------------------" >> $output_file
                cat "$file" >> $output_file
                printf "\n\n\n\n\n\n\n\n\n\n" >> $output_file
            fi
        done
    fi
done

# Checking individual user crontabs
echo "===== User Crontabs =====" >> $output_file
printf "\n\n" >> $output_file
for user in $(cut -f1 -d: /etc/passwd); do
    user_cron=$(crontab -l -u $user 2>/dev/null)
    if [ ! -z "$user_cron" ]; then
        echo "------------------------------ $user's Crontab ------------------------------" >> $output_file
        echo "$user_cron" >> $output_file
        printf "\n\n\n\n\n\n\n\n\n\n" >> $output_file
    fi
done

# Checking at jobs
echo "===== At Jobs =====" >> $output_file
printf "\n\n" >> $output_file
atq >> $output_file
printf "\n\n" >> $output_file

echo "Data saved to $output_file"
