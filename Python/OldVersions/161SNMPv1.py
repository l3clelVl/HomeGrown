import subprocess

def execute_command(command):
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()
    return output.decode().strip(), error.decode().strip()

def main():
    ip_list_file = input("Enter the filename containing the IP list: ")
    output_file = input("Enter the output filename prefix: ")

    # Step 1: Identify SNMP servers with onesixtyone
    print("Step 1: Identifying SNMP servers with onesixtyone...")
    onesixtyone_output, onesixtyone_error = execute_command("onesixtyone -c community.tmp -i {} 2>&1".format(ip_list_file))
    with open(output_file + "_onesixtyone", "w") as f:
        f.write(onesixtyone_output)

    # Step 2: Create community.tmp file
    print("Step 2: Creating community.tmp file...")
    community_data = "public\nprivate\nmanager"
    with open("community.tmp", "w") as f:
        f.write(community_data)

    # Step 3: Execute SNMPWalk for positive results
    print("Step 3: Executing SNMPWalk for positive results...")
    with open(ip_list_file) as f:
        ips = f.read().splitlines()
    total_ips = len(ips)
    completed_ips = 0
    for ip in ips:
        snmpwalk_output, snmpwalk_error = execute_command("snmpwalk -c public -v 2c {} 2>&1".format(ip))
        if snmpwalk_error:
            print("Error for IP {}: {}".format(ip, snmpwalk_error))
        else:
            with open(output_file + "_SNMPd", "a") as f:
                f.write("IP: {}\n".format(ip))
                f.write(snmpwalk_output)
        completed_ips += 1
        progress = (completed_ips / total_ips) * 100
        print("Progress: {:.2f}%".format(progress))

    # Step 6: Remove community.tmp file
    print("Step 6: Removing community.tmp file...")
    execute_command("rm community.tmp")

    print("Script completed.")

if __name__ == "__main__":
    main()
