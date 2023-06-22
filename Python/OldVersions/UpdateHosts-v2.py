'''
1) Prompt the user for a hostname
2) Search the /etc/hosts file for all matches containing the contiguous case-insensitive hostname to include lines beginning with a hashtag/pound symbol
3) Return matching lines from "2)" to terminal output for user viewing with matching line numbers from their respective line in the /etc/hosts file
4) Prompt the user, if they want to: Change the IP, add a new hostname, remove a line, or exit the script
4a) If change IP, then prompt the user for:
4a1) The matching line number
4a2) IP input of either IPv4 or IPv6
4a2i) Prompt for input of option for IPv4 or IPv6, but sanitize the input to be only the chosen format of IPv4 or IPv6.
4b) If adding a new hostname, prompt for two new, but separate inputs:
4b1) New hostname that doesn't conflict with an existing entry
4b2) The new IP follows the same guidance as from "4a2i)"
5) Remove includes lines commented out
5a) Specified using the SED command as matches.remove wasn't removing commented lines
'''
import re
import subprocess

def prompt_user(prompt):
    return input(prompt)

def search_hosts_file(hostname):
    matches = []
    with open('/etc/hosts', 'r') as hosts_file:
        for line_number, line in enumerate(hosts_file, start=1):
            if re.search(fr'^(?:[^#].*)?\b{re.escape(hostname)}\b', line, re.IGNORECASE) or re.search(fr'^(?:#.*\s)?\b{re.escape(hostname)}\b', line, re.IGNORECASE):
                matches.append((line_number, line))
    return matches


def display_matches(matches):
    for line_number, line in matches:
        print(f'{line_number}: {line}')

def change_ip(matches):
    line_number = int(prompt_user('Enter the line number to change the IP: '))
    new_ip = prompt_user('Enter the new IP: ')
    matches[line_number - 1] = (matches[line_number - 1][0], re.sub(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', new_ip, matches[line_number - 1][1]))
    print('IP changed successfully!')

def add_hostname(matches):
    new_hostname = prompt_user('Enter the new hostname: ')
    new_ip = prompt_user('Enter the IP for the new hostname: ')
    matches.append((len(matches) + 1, f'{new_ip}\t{new_hostname}'))
    print('New hostname added successfully!')

def remove_line(matches):
    line_number = int(prompt_user('Enter the line number to remove: '))
    if 1 <= line_number <= len(matches):
        line_to_remove = matches[line_number - 1]
        sed_command = f'{line_to_remove[0]}d'
        subprocess.run(['sudo', 'sed', '-i', sed_command, '/etc/hosts'], check=True)
        print('Line removed successfully!')
    else:
        print('Invalid line number. Please try again.')

def main():
    hostname = prompt_user('Enter the hostname to search: ')
    matches = search_hosts_file(hostname)
    if matches:
        display_matches(matches)
        while True:
            choice = prompt_user('Options: (1) Change IP, (2) Add new hostname, (3) Remove line, (4) Exit. Enter your choice: ')
            if choice == '1':
                change_ip(matches)
            elif choice == '2':
                add_hostname(matches)
            elif choice == '3':
                remove_line(matches)
            elif choice == '4':
                break
            else:
                print('Invalid choice. Try again.')
    else:
        print('No matches found.')

if __name__ == '__main__':
    main()
