'''"""
1) Prompt the user for a hostname
2) Search the /etc/hosts file for all matches containing the contiguous case-insensitive hostname
3) Return matching lines from "2)" to terminal output for user viewing with matching line numbers from their respective line in the /etc/hosts file
4) Prompt the user, if they want to: Change the IP, add a new hostname, or exit the script
4a) If change IP, then prompt the user for:
4a1) The matching line number
4a2) IP input of either IPv4 or IPv6
4a2i) Prompt for input of option for IPv4 or IPv6, but sanitize the input to be only the chosen format of IPv4 or IPv6.
4b) If adding a new hostname, prompt for two new, but separate inputs:
4b1) New hostname that doesn't conflict with an existing entry
4b2) The new IP follows the same guidance as from "4a2i)"
"""'''



import re

def search_hosts_file(hostname):
    with open('/etc/hosts', 'r') as hosts_file:
        lines = hosts_file.readlines()
        matches = []
        for i, line in enumerate(lines, 1):
            if re.search(fr"\b{re.escape(hostname)}\b", line, re.IGNORECASE):
                matches.append((i, line.strip()))
        return matches

def display_matches(matches):
    if not matches:
        print("No matches found.")
        return

    for line_number, line in matches:
        print(f"{line_number}: {line}")

def change_ip(matches):
    line_number = int(input("Enter the line number of the entry to change the IP: "))
    new_ip = input("Enter the new IP address: ")
    # You can add input validation for IP format (IPv4 or IPv6) if required

    if 1 <= line_number <= len(matches):
        line_index = line_number - 1
        _, old_line = matches[line_index]
        new_line = re.sub(r"\b(\d{1,3}\.){3}\d{1,3}\b", new_ip, old_line)
        matches[line_index] = (line_number, new_line)
        print(f"Updated line {line_number} with new IP: {new_line}")
    else:
        print("Invalid line number.")

def add_hostname(matches):
    new_hostname = input("Enter the new hostname: ")
    new_ip = input("Enter the IP address for the new hostname: ")
    # You can add input validation for IP format (IPv4 or IPv6) if required

    new_entry = f"{new_ip}\t{new_hostname}"
    matches.append((len(matches) + 1, new_entry))
    print(f"Added new entry: {new_entry}")

def main():
    hostname = input("Enter a hostname to search in /etc/hosts: ")
    matches = search_hosts_file(hostname)

    if matches:
        display_matches(matches)

        while True:
            option = input("\nOptions:\n1. Change IP\n2. Add a new hostname\n3. Exit\nSelect an option: ")

            if option == '1':
                change_ip(matches)
            elif option == '2':
                add_hostname(matches)
            elif option == '3':
                break
            else:
                print("Invalid option. Please try again.")

    else:
        print("No matches found.")

if __name__ == "__main__":
    main()
