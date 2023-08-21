#!/bin/bash

# Saving the results to ~/Untitled-SchTasks.txt
output_file=~/Untitled-SchTasks.txt

# Clearing the output file before appending new data
> $output_file

# Checking system-wide crontab
echo "===== System-wide Crontab =====" >> $output_file
cat /etc/crontab >> $output_file
echo "\n\n" >> $output_file

# Checking cron jobs in /etc/cron.d/
echo "===== /etc/cron.d/ Jobs =====" >> $output_file
for job_file in /etc/cron.d/*; do
    echo "---- $job_file ----" >> $output_file
    cat $job_file >> $output_file
    echo "\n" >> $output_file
done
echo "\n" >> $output_file

# Checking daily, weekly, and monthly cron jobs
for period in daily weekly monthly; do
    echo "===== /etc/cron.$period Jobs =====" >> $output_file
    for job_file in /etc/cron.$period/*; do
        if [ -f "$job_file" ]; then
            echo "---- $job_file ----" >> $output_file
            cat $job_file >> $output_file
            echo "\n" >> $output_file
        fi
    done
    echo "\n" >> $output_file
done

# Checking individual user crontabs
echo "===== User Crontabs =====" >> $output_file
for user in $(cut -f1 -d: /etc/passwd); do
    user_cron=$(crontab -l -u $user 2>/dev/null)
    if [ ! -z "$user_cron" ]; then
        echo "---- $user's Crontab ----" >> $output_file
        echo "$user_cron" >> $output_file
        echo "\n" >> $output_file
    fi
done

# Checking at jobs
echo "===== At Jobs =====" >> $output_file
atq >> $output_file
echo "\n\n" >> $output_file

echo "Data saved to $output_file"
