#!/bin/bash

# Check if onesixtyone is installed
if ! command -v onesixtyone &> /dev/null; then
    echo "onesixtyone could not be found"
    exit
fi

# Check if file is provided as an argument
if [ -z "$1" ]; then
    echo "Please provide a filename as an argument"
    exit
fi

# Perform SNMP scan
onesixtyone -c community.txt -i "$1" > "${1}_SNMPd"
