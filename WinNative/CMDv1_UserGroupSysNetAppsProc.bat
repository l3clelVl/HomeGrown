:: Saves in C:\temp\notes_(time).txt

@echo off
setlocal

:: Get the current timestamp
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%

:: Start the logging
set logFile=C:\temp\notes_%timestamp%.txt
echo Script start time: %timestamp% > %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%

:: User info
echo User Info: >> %logFile%
whoami /all >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%

:: Group info
echo Group Info: >> %logFile%
net localgroup | findstr /i "admin backup remote" >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%

:: System info
echo System Info: >> %logFile%
systeminfo >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%

:: Network info
echo Network Info: >> %logFile%
ipconfig /all >> %logFile%
route print >> %logFile%
netstat -ano >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%

:: 32-bit Apps
echo 32-bit Apps: >> %logFile%
reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s | findstr DisplayName >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%

:: 64-bit Apps
echo 64-bit Apps: >> %logFile%
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "*" /t REG_SZ /v DisplayName >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%
echo. >> %logFile%

:: Running processes
echo Running Processes: >> %logFile%
tasklist >> %logFile%

endlocal
