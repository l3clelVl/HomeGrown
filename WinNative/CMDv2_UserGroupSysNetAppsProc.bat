@echo off
setlocal

:: Get the current timestamp
set timestamp=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%

:: Set the log file path
set logFile=C:\temp\notes_%timestamp%.txt

:: Start the logging
(
  echo Script start time: %timestamp%
  echo.
  echo.
  echo.
  echo.
  echo.

  :: User info
  echo User Info:
  whoami /all

  echo.
  echo.
  echo.
  echo.
  echo.

  :: Group info
  echo Group Info:
  net localgroup | findstr /i "admin backup remote"

  echo.
  echo.
  echo.
  echo.
  echo.

  :: System info
  echo System Info:
  systeminfo

  echo.
  echo.
  echo.
  echo.
  echo.

  :: Network info
  echo Network Info:
  ipconfig /all
  route print
  netstat -ano

  echo.
  echo.
  echo.
  echo.
  echo.

  :: 32-bit Apps
  echo 32-bit Apps:
  reg query "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s

  echo.
  echo.
  echo.
  echo.
  echo.

  :: 64-bit Apps
  echo 64-bit Apps:
  reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "*" /t REG_SZ /v

  echo.
  echo.
  echo.
  echo.
  echo.

  :: Running processes
  echo Running Processes:
  tasklist

  echo.
  echo.
  echo.
  echo.
  echo.

  :: Generate software list using WMIC
  echo Software List using WMIC:
  wmic product get name, version

  echo.
  echo.
  echo.
  echo.
  echo.

  :: Generate software list using Get-ItemProperty
  echo Software List using Get-ItemProperty:
  powershell -command "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize"

  echo.
  echo.
  echo.
  echo.
  echo.

  :: Generate software list using Get-WmiObject
  echo Software List using Get-WmiObject:
  powershell -command "Get-WmiObject -Class Win32_Product | Select-Object Name, Version, Vendor, InstallDate | Format-Table -AutoSize"

) > "%logFile%"

endlocal
