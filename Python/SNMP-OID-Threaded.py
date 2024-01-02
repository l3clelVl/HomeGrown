##########################
# https://github.com/l3clelVl/HomeGrown/blob/14d82930b581230f478c0ec4b445f2c5541ae897/Python/SNMP-OID-Threaded.py
# Author: DeMzDaRulez
# OG: 29Jul23, CAO: 1Jan24
# Purpose: Find all the things from SNMP
# Actions: Script will produce a file in CWD for each declaration in the "oids" array
# Usage: python ThisScript.py Target
##########################
#/usr/bin/env python

import subprocess
import threading
import argparse

def run_snmpwalk(oid, hostname):
    # Replace "::" with "--" in the OID and use a hyphen "-" in the output file name
    oid_filename = oid.replace('::', '--').replace('.', '_')
    output_file = f"{hostname}-SNMP-{oid_filename}.txt"
    command = f"snmpwalk -t 10 -Oa -v2c -c public {hostname} {oid} > {output_file}"
    subprocess.run(command, shell=True)
    print(f"Finished OID {oid}")

def main():
    parser = argparse.ArgumentParser(description="Run SNMP walks for multiple OIDs.")
    parser.add_argument("hostname", help="Hostname or IP address")
    args = parser.parse_args()

    oids = [
	"NET-SNMP-EXTEND-MIB::nsExtendObjects",
	"1.3.6.1.2.1.25.1.6.0",
	"1.3.6.1.2.1.25.4.2.1.2",
	"1.3.6.1.2.1.25.4.2.1.4",
	"1.3.6.1.2.1.25.2.3.1.4",
	"1.3.6.1.2.1.25.6.3.1.2",
	"1.3.6.1.4.1.77.1.2.25",
	"1.3.6.1.2.1.6.13.1.3",
	"1.3.6.1.2.1.2.2.1.2",
	"1.3.6.1.2.1.31.1.1.1.1",
	"1.3.6.1.2.1.31.1.1.1.18",
    ]

    threads = []
    for oid in oids:
        thread = threading.Thread(target=run_snmpwalk, args=(oid, args.hostname))
        threads.append(thread)
        thread.start()

    # Wait for all threads to complete
    for thread in threads:
        thread.join()

if __name__ == "__main__":
    main()
