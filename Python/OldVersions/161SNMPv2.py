import subprocess
import sys
import os
from tqdm import tqdm

def execute_command(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    output, error = process.communicate()
    return output.decode().strip()

def write_to_file(filename, content):
    with open(filename, 'a') as file:
        file.write(content)

def remove_file(filename):
    if os.path.exists(filename):
        os.remove(filename)

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <ip_list_file>")
        return

    ip_list_file = sys.argv[1]

    # Step 1: Create community.tmp file
    write_to_file('community.tmp', 'public\nprivate\nmanager\n')

    # Step 2: ID SNMP servers with onesixtyone
    ip_list = []
    with open(ip_list_file, 'r') as file:
        ip_list = file.read().strip().split('\n')

    progress_bar = tqdm(total=len(ip_list), desc='Scanning SNMP servers')

    for ip in ip_list:
        # Step 3: Run onesixtyone with option -i
        command = f'onesixtyone -c community.tmp -i {ip}'
        snmp_result = execute_command(command)

        if snmp_result:
            # Step 4: Run SNMPWalk to list running processes
            command = f'snmpwalk -c public -v2c {ip} 1.3.6.1.2.1.25.4.2.1.2'
            snmpwalk_result = execute_command(command)

            # Step 5: Append output to file
            output_filename = ip_list_file + '_SNMPd'
            write_to_file(output_filename, snmpwalk_result + '\n')

        progress_bar.update(1)

    progress_bar.close()

    # Step 6c: Debugging and comments
    print('SNMP scanning completed.')

    # Step 7: Remove community.tmp file
    remove_file('community.tmp')

if __name__ == '__main__':
    main()
