# PowerShell script to gather exhaustive system information

# Operating System Details
echo "----- OS Details -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
wmic os get caption,version,osarchitecture,servicepackmajorversion | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Uptime
echo "----- Uptime -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
systeminfo | findstr "System Boot Time" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
net statistics workstation | find "Statistics since" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Hardware Information
echo "----- Hardware Information -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
wmic cpu get caption, deviceid, numberofcores, maxclockspeed, status | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
wmic memorychip get capacity, speed | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
wmic diskdrive get size,status,model | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
wmic bios get serialnumber, version | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Environment Variables
echo "----- Environment Variables -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
set | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# System Configuration & Settings
echo "----- System Configuration & Settings -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
systeminfo | findstr /C:"Time Zone" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
netsh winhttp show proxy | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
echo %windir% | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
hostname | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Installed Patches/Updates
echo "----- Installed Patches/Updates -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
wmic qfe list | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Drivers
echo "----- Drivers -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
driverquery | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Windows Services
echo "----- Windows Services -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
wmic service get displayname, state | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Scheduled Tasks
echo "----- Scheduled Tasks -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
schtasks /query | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Loaded Modules
echo "----- Loaded Modules -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
tasklist /M | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Environment Settings
echo "----- Environment Settings -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
echo %TEMP% | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
echo %USERPROFILE% | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Current System Language
echo "----- Current System Language -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
systeminfo | findstr /C:"System Locale" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Licensing
echo "----- Licensing -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
slmgr /dli | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Startup Programs
echo "----- Startup Programs -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
wmic startup list full | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# Registry Checks
echo "----- Registry Checks -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append

# End of Script
echo "----- End of System Information Collection -----" | Out-File "C:\Users\$env:USERNAME\Untitled-SysInfo.txt" -Append
