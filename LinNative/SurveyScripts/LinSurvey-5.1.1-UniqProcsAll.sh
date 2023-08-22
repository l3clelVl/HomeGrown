	#!/bin/bash
	    
	declare -A logged_processes # Declare an associative array
	    
	while true; do
	    CMD=$(ps -efwww | grep "$1" | grep -Ev "grep|process-check.sh")
	    
	    # Check if this process has been logged before
	    if [[ ! -z "$CMD" && -z "${logged_processes["$CMD"]}" ]]; then
	        echo "$CMD" >> Untitled-AllBackgroundProcess.txt
	        logged_processes["$CMD"]=1 # Mark this process as logged
	    fi
	    
	    sleep 1 # Sleep for 1 second before checking again
done
