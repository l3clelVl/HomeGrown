#!/bin/bash

###########################################################################
# Script Name: Process Info Gatherer
# Description: This script collects detailed information about the system's running processes using tools like top, ps, pstree, netstat,
#              ss, and lsof. The gathered data is saved to specific files in the user's home directory.
# Author: brdman come, he's fly in any weather
# Date: 21Aug2023
###########################################################################


# If any errors: Bail!
set -e -o pipefail

##################################################################################################################################

# Check for shred command and use rm if not available
if command -v shred > /dev/null; then
    shred_em="shred -u"
else
    shred_em="rm"
fi

# Make a local temp directory to avoid permission issues
my_temp_dir="$HOME/temp"
mkdir -p "$my_temp_dir"

##################################################################################################################################

create_toprc() {
    local toprc_file="$1"

    mkdir -p "$(dirname "$toprc_file")"

    cat << 'EOF' > "$toprc_file"
top's Config File (Linux processes with windows)
Id:k, Mode_altscr=0, Mode_irixps=1, Delay_time=3.0, Curwin=0
Def	fieldscur=  77   75   81  139  102  104  118  122  128  110  136  116  114   78   82   84   86   88   90   92 
		    94   96   98  100  106  108  112  120  124  126  130  132  134  140  142  144  146  148  150  152 
		   154  156  158  160  162  164  166  168  170  172  174  176  178  180  182  184  186  188  190  192 
		   194  196  198  200  202  204  206  208  210  212  214  216  218  220  222  224  226  228  230  232 
		   234  236  238  240  242  244  246  248  250  252  254  256  258  260  262  264  266  268  270  272 
	winflags=193844, sortindx=18, maxtasks=0, graph_cpus=0, graph_mems=0, double_up=0, combine_cpus=0, core_types=0
	summclr=1, msgsclr=1, headclr=3, taskclr=1
Job	fieldscur=  75   77  115  111  117   80  103  105  137  119  123  128  120   79  139   82   84   86   88   90 
		    92   94   96   98  100  106  108  112  124  126  130  132  134  140  142  144  146  148  150  152 
		   154  156  158  160  162  164  166  168  170  172  174  176  178  180  182  184  186  188  190  192 
		   194  196  198  200  202  204  206  208  210  212  214  216  218  220  222  224  226  228  230  232 
		   234  236  238  240  242  244  246  248  250  252  254  256  258  260  262  264  266  268  270  272 
	winflags=193844, sortindx=0, maxtasks=0, graph_cpus=0, graph_mems=0, double_up=0, combine_cpus=0, core_types=0
	summclr=6, msgsclr=6, headclr=7, taskclr=6
Mem	fieldscur=  75  117  119  120  123  125  127  129  131  154  132  156  135  136  102  104  111  139   76   78 
		    80   82   84   86   88   90   92   94   96   98  100  106  108  112  114  140  142  144  146  148 
		   150  152  158  160  162  164  166  168  170  172  174  176  178  180  182  184  186  188  190  192 
		   194  196  198  200  202  204  206  208  210  212  214  216  218  220  222  224  226  228  230  232 
		   234  236  238  240  242  244  246  248  250  252  254  256  258  260  262  264  266  268  270  272 
	winflags=193844, sortindx=21, maxtasks=0, graph_cpus=0, graph_mems=0, double_up=0, combine_cpus=0, core_types=0
	summclr=5, msgsclr=5, headclr=4, taskclr=5
Usr	fieldscur=  75   77   79   81   85   97  115  111  117  137  139   82   86   88   90   92   94   98  100  102 
		   104  106  108  112  118  120  122  124  126  128  130  132  134  140  142  144  146  148  150  152 
		   154  156  158  160  162  164  166  168  170  172  174  176  178  180  182  184  186  188  190  192 
		   194  196  198  200  202  204  206  208  210  212  214  216  218  220  222  224  226  228  230  232 
		   234  236  238  240  242  244  246  248  250  252  254  256  258  260  262  264  266  268  270  272 
	winflags=193844, sortindx=3, maxtasks=0, graph_cpus=0, graph_mems=0, double_up=0, combine_cpus=0, core_types=0
	summclr=3, msgsclr=3, headclr=2, taskclr=3
Fixed_widest=0, Summ_mscale=1, Task_mscale=0, Zero_suppress=0, Tics_scaled=0
EOF

    if [ -f "$toprc_file" ]; then
        echo "Configuration file $toprc_file created for top."
    else
        echo "Failed to create configuration file $toprc_file."
    fi

# 1. Create $HOME/.toprc
create_toprc "$HOME/.toprc"

# 2. Create $HOME/.config/procps/toprc
create_toprc "$HOME/.config/procps/toprc"

# 3. Create $XDG_CONFIG_HOME/procps/toprc if XDG_CONFIG_HOME is set
if [ -n "$XDG_CONFIG_HOME" ]; then
    create_toprc "$XDG_CONFIG_HOME/procps/toprc"
fi
}

# Function to execute commands, append to the output file, and check for errors
execute_command() {
    if ! eval "$1" >> "$2" 2>>error_log.txt; then
        printf "Error executing: $1\n"
        printf "Error details:\n"
        cat error_log.txt
        rm error_log.txt
    fi
}

delete_item() {
    local item_to_delete="$1"
    if [ -f "$item_to_delete" ]; then
        $shred_em "$item_to_delete"
    elif [ -d "$item_to_delete" ]; then
        rm -r "$item_to_delete"
    fi

    if [ $? -ne 0 ]; then
        printf "Failed to delete $item_to_delete."
    fi
}



##################################################################################################################################

# Saving results to ~/Untitled-Processes.txt
output_file_1="$HOME/Untitled-1MOTPUSorted.txt"
output_file_2="$HOME/Untitled-Processes-PS,PST,NS,SS.txt"
output_file_3="$HOME/Untitled-BulkProcessesLSOF.txt"
output_file_4="$HOME/Untitled-SlimProcessesLSOF.txt"
temp_top_output_file_1=$(mktemp --tmpdir="$my_temp_dir")
temp_top_output_file_2=$(mktemp --tmpdir="$my_temp_dir")

# Clearing the output file before adding new data
> $output_file_1
> $output_file_2
> $output_file_3
> $output_file_4

##################################################################################################################################



# Top Processes
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ Top Processes ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"

# Capture top's output
printf "Capturing Top's configured output...\n"
execute_command "top -n 3 -b" "$temp_top_output_file_1"

# Extract the header and remove duplicates
printf "Extracting the header and removing duplicates from Top's config'd output...\n"
execute_command "(head -n 7 $temp_top_output_file_1 && tail -n +8 $temp_top_output_file_1 | sort -u)" "$temp_top_output_file_2"

# Extract the header and sort by PID
printf "Extracting the header and sorting by PID of Top's uniq config'd output...\n"
execute_command "(grep -m 1 'PID USER' $temp_top_output_file_2 && egrep -v '(PID USER|Cpu\(s\)|MiB|Tasks\:|top -)' $temp_top_output_file_2 | sort -k1 -n )" "$output_file_1"

echo "Top's processes have been processed"
printf "\n%.0s" {1..5}


##################################################################################################################################


printf "Top Process information gathered, processed, and saved to $output_file_1, and removed both Untitled-1MinOfTopProcs.txt and Untitled-1MOTPUniq.txt\n"

# More Processes
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ Processes presented by PS, PST, NetStat, and SS ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"

# Get a snapshot of the current processes
printf "==== Current Running Processes (ps aux) ====\n"
execute_command "ps aux" "$output_file_2"

# Display a tree of processes
printf "==== Process Tree (pstree) ====\n"
execute_command "pstree" "$output_file_2"

# Check for processes listening on sockets
printf "==== Listening Processes (netstat -tuln) ====\n"
execute_command "netstat -tuln" "$output_file_2"

# Check for processes listening on sockets using ss
printf "==== Listening Processes (ss -tuln) ====\n"
execute_command "ss -plunt" "$output_file_2"


##################################################################################################################################


# Last long bit Processes
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ Processes presented by LSOF as a catch-all ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"

# LiSt Open files
echo "LiSt Open Files"
printf "==== Open Files by Processes (lsof) ====\n"
execute_command "lsof -F cpun | awk 'BEGIN {OFS=\"\t\t\t\"} /^c/{command=\$0; next} /^p/{pid=\$0; next} /^u/{user=\$0; next} /^n/{gsub(/^n/,\"\",\$0); name=\$0; print command, pid, user, name}'" "$output_file_3"

printf "Process information gathered and saved to $output_file_3\n"


# Remove a bunch of directories and unusable info about open files processes
echo "LiSt a more manageable amount of Open Files"
execute_command "cat $output_file_3 | \
sort -u | \
grep -i -vE '/proc/|/sys/|/usr/share/|/lib/|/usr/bin/|/usr/sbin/|/var/cache/|permission denied|type=STREAM|memfd:pipewire-memfd|KOBJECT|inotify|chromium.chromium|/dev/null|\[\*\]' | \
grep -vE \"^.*\$HOME/.(config|cache)\" | sort -k4" "$output_file_4"








##################################################################################################################################


# Cleanup after yourself!
delete_item "$temp_top_output_file_1"
delete_item "$temp_top_output_file_2"
delete_item "$my_temp_dir"
delete_item "$HOME/.toprc"
delete_item "$HOME/.config/procps/toprc"
[ -n "$XDG_CONFIG_HOME" ] && delete_item "$XDG_CONFIG_HOME/procps/toprc"