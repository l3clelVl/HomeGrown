#/usr/bin/env python

import sys

# Function to read LOLBins from a file
def read_lolbins(filename):
    with open(filename, 'r') as file:
        return [line.strip() for line in file if line.strip()]

# Check for the correct number of arguments
if len(sys.argv) != 2:
    print("Usage: python WhereTheLOLBinS.py <filename>")
    sys.exit(1)

# Read LOLBins from the file specified as the first argument
lolbins = read_lolbins(sys.argv[1])

# Generate the formatted strings
postgresql_format = f"which {{{','.join(lolbins)}}}"
burpsuite_format = f"which+{{{'+'.join(lolbins)}}}"
linux_format = f'for cmd in {" ".join(lolbins)}; do which "$cmd"; done'
windows_cmd_format = f'for %i in ({" ".join(lolbins)}) do @where %i 2>nul && echo Found: %i'
windows_ps_format = '@("' + '", "'.join(lolbins) + '") | ForEach-Object {{ if (Get-Command $_ -ErrorAction SilentlyContinue) {{ Write-Host "Found: $_" }} }}'

# Combine them into a single output
script_content = f"""
# PostgreSQL format:
{postgresql_format}

# BurpSuite format:
{burpsuite_format}

# Linux format:
{linux_format}

# Windows Cmd format:
{windows_cmd_format}

# Windows PowerShell format:
{windows_ps_format}
"""

# Print the combined output
print(script_content)
