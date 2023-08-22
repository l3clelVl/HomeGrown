	#!/bin/bash
	    
	declare -A logged_processes # Declare an associative array
	    
	while true; do
	    # Get processes run by user accounts (UID >= 1000) or root (UID = 0)
	    CMD=$(ps -eo uid,cmd | awk '$1 >= 1000 || $1 == 0 {print $0}' | grep "$1" | grep -Ev "grep|process-check.sh")
	    
	    # Check if this process has been logged before
	    if [[ ! -z "$CMD" && -z "${logged_processes["$CMD"]}" ]]; then
	        echo "$CMD" >> Untitled-Users-n-RootBackgroundProcess.txt
	        logged_processes["$CMD"]=1 # Mark this process as logged
	    fi
	    
	    sleep 1 # Sleep for 1 second before checking again
done