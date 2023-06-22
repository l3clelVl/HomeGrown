'''
1) Prompt the user for a hostname
2) Search the /etc/hosts file for all matches containing the contiguous case-insensitive hostname to include lines beginning with a hashtag/pound symbol
3) Return matching lines from "2)" to terminal output for user viewing with matching line numbers from their respective line in the /etc/hosts file
4) Prompt the user, if they want to: Change the IP, add a new hostname, remove a line, or exit the script
4.1) add "search for a new hostname"
4.2) Options display vertical instead of horizontal
4a) If change IP, then prompt the user for:
4a1) The matching line number
4a2) IP input of either IPv4 or IPv6
4a2i) Prompt for input of option for IPv4 or IPv6, but sanitize the input to be only the chosen format of IPv4 or IPv6.
4b) If adding a new hostname, prompt for two new, but separate inputs:
4b1) New hostname that doesn't conflict with an existing entry
4b2) The new IP follows the same guidance as from "4a2i)"
5) If a hostname isn't found, then return to menu
6) After a hostname & IP are prepended to /etc/hosts, then check and confirm it's created properly
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
    new_line = f'{new_ip}\t{new_hostname}\n'
    with open('/etc/hosts', 'r+') as hosts_file:
        content = hosts_file.read()
        hosts_file.seek(0, 0)
        hosts_file.write(new_line + content)
    print(f'Line added successfully:\n{new_line}')
    validate_line(new_line, new_hostname, new_ip)

def validate_line(new_line, new_hostname, new_ip):
    with open('/etc/hosts', 'r') as hosts_file:
        lines = hosts_file.readlines()
        first_line = lines[0]
        if first_line != new_line:
            remove_line_confirmation = prompt_user('The line added does not match the first line in /etc/hosts. Do you want to remove the incorrect line? (y/n): ')
            if remove_line_confirmation.lower() == 'y':
                with open('/etc/hosts', 'w') as hosts_file:
                    for line in lines[1:]:
                        hosts_file.write(line)
                print('Incorrect line removed.')
            else:
                print('Please change my script because it\'s not functioning properly.')

def get_max_line_number():
    process = subprocess.run(['wc', '-l', '/etc/hosts'], capture_output=True, text=True)
    output = process.stdout.strip()
    max_line_number = int(output.split()[0])
    return max_line_number

def remove_line(matches):
    max_line_number = get_max_line_number()
    line_number = int(prompt_user(f'Enter the line number to remove (1-{max_line_number}): '))
    if 1 <= line_number <= max_line_number:
        line_to_remove = line_number
        sed_command = f'{line_to_remove}d'
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
            print('Options:')
            print('(1) Change IP')
            print('(2) Add new entry (hostname and IP)')
            print('(3) Remove line')
            print('(4) Search for a hostname')
            print('(5) Exit')
            choice = prompt_user('Enter your choice: ')
            if choice == '1':
                change_ip(matches)
            elif choice == '2':
                add_hostname(matches)
            elif choice == '3':
                remove_line(matches)
            elif choice == '4':
                return main()  # Recursively call the main function for the new search
            elif choice == '5':
                return
            else:
                print('Invalid choice. Try again.')

        main()  # Recursively call the main function for the new search
    else:
        print('No matches found.')
        main()  # Recursively call the main function to search for a new hostname

if __name__ == '__main__':
    main()
