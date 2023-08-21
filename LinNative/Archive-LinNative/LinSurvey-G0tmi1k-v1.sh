#!/bin/bash

echo "[+] Checking Operating System Information..."
cat /etc/issue
cat /etc/*-release
cat /etc/lsb-release      # Debian based
cat /etc/redhat-release   # Redhat based
echo

echo "[+] Checking Kernel Version..."
cat /proc/version
uname -a
uname -mrs
rpm -q kernel
dmesg | grep Linux
ls /boot | grep vmlinuz-
echo

echo "[+] Checking Environmental Variables..."
cat /etc/profile
cat /etc/bashrc
cat ~/.bash_profile
cat ~/.bashrc
cat ~/.bash_logout
env
set
echo

echo "[+] Checking for Printers..."
lpstat -a
echo

echo "[+] Checking Applications & Services..."
ps aux
ps -ef
top
cat /etc/services
ps aux | grep root
ps -ef | grep root
ls -alh /usr/bin/
ls -alh /sbin/
dpkg -l
rpm -qa
ls -alh /var/cache/apt/archivesO
ls -alh /var/cache/yum/
echo

# ... and so on for all sections

