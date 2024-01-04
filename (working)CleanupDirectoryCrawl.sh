#!/bin/bash
# Is cutting too much from the "http"
awk -F/ '/http:\/\// { split($1, a, " "); print a[1] "/" $4 }' "$1" | sort -u -k2,2 -k1,1 > "$2"
