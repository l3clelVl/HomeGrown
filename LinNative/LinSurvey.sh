#!/bin/bash

# Saving the output to ~/Untitled.txt
output_file=~/Untitled.txt

# Clearing any previous content in the file
> $output_file

# Fetching the current username
echo "1. Current User Information:" >> $output_file
echo "Output of whoami:" >> $output_file
whoami >> $output_file
echo "Output of id:" >> $output_file
id >> $output_file
echo "Output of echo $USER:" >> $output_file
echo $USER >> $output_file
echo "Output of echo $HOME:" >> $output_file
echo $HOME >> $output_file

# Listing all users on the system
echo "\\n2. List All Users on the System:" >> $output_file
echo "Output of cat /etc/passwd:" >> $output_file
cat /etc/passwd >> $output_file
echo "Output of cut -d: -f1 /etc/passwd:" >> $output_file
cut -d: -f1 /etc/passwd >> $output_file
echo "Output of getent passwd:" >> $output_file
getent passwd >> $output_file

# User's Last Login
echo "\\n3. User's Last Login:" >> $output_file
echo "Output of last:" >> $output_file
last >> $output_file
echo "Output of lastlog:" >> $output_file
lastlog >> $output_file

# Group Memberships
echo "\\n4. Group Memberships:" >> $output_file
echo "Output of groups:" >> $output_file
groups >> $output_file

# Users currently logged in
echo "\\n5. Users Currently Logged In:" >> $output_file
echo "Output of who:" >> $output_file
who >> $output_file
echo "Output of w:" >> $output_file
w >> $output_file
echo "Output of users:" >> $output_file
users >> $output_file

# Home Directory Contents
echo "\\n6. Home Directory Contents:" >> $output_file
echo "Output of ls -lah ~:" >> $output_file
ls -lah ~ >> $output_file

# User Account Details
echo "\\n7. User Account Details:" >> $output_file
echo "Output of finger:" >> $output_file
finger >> $output_file 2>&1
echo "Output of chage -l:" >> $output_file
chage -l $USER >> $output_file 2>&1

# Default Shell
echo "\\n8. Default Shell:" >> $output_file
echo "Output of echo $SHELL:" >> $output_file
echo $SHELL >> $output_file

# Other User-Related Files
echo "\\n9. Other User-Related Files:" >> $output_file
echo "Output of cat /etc/login.defs:" >> $output_file
cat /etc/login.defs >> $output_file
echo "Output of cat /etc/default/useradd:" >> $output_file
cat /etc/default/useradd >> $output_file

echo "\\nScript Execution Completed!" >> $output_file
