##########################
# https://github.com/l3clelVl/HomeGrown/blob/14d82930b581230f478c0ec4b445f2c5541ae897/Python/SNMP-OID-Threaded.py
# Author: DeMzDaRulez
# OG: 29Jul23, CAO: 16Feb26
# Purpose: Find all the things SNMP
# Actions: 1) Run onesixtyone to find communities, 2) For each community, run snmpwalk/snmpbulkwalk on specified OIDs, 3) Save output to files named like "Target-SNMP-Community-OID
    # Example: If onesixtyone finds "public" and "private", and the oids array is ["NET-SNMP-EXTEND-MIB::nsExtendObjects", ".1"], then the script will produce 4 files in CWD:
        # Target-SNMP-public-NET-SNMP-EXTEND-MIB--nsExtendObjects.txt
        # Target-SNMP-public-.1.txt
        # Target-SNMP-private-NET-SNMP-EXTEND-MIB--nsExtendObjects.txt
        # Target-SNMP-private-.1.txt
# Usage: python3 SNMP-OID-Threaded.py <hostname> [--wordlist <file>] [--bulkwalk] [--timeout <seconds>] [--oids <oid1> <oid2> ...] [--threads <num>] [--dry-run]
##########################
#!/usr/bin/env python3

import subprocess
import threading
import argparse
import shlex
import re
import os

def run_command(cmd_args, dry_run=False, capture_output=False):
    if dry_run:
        print("DRY-RUN:", " ".join(shlex.quote(a) for a in cmd_args))
        return ""
    try:
        if capture_output:
            return subprocess.check_output(cmd_args, stderr=subprocess.DEVNULL, text=True)
        subprocess.run(cmd_args, check=False)
    except FileNotFoundError:
        print(f"Command not found: {cmd_args[0]}")
    return None

def run_onesixtyone(hostname, wordlist, dry_run=False):
    cmd = ["onesixtyone", "-c", wordlist, hostname]
    out = run_command(cmd, dry_run=dry_run, capture_output=not dry_run)
    communities = set()
    if dry_run or not out:
        return communities
    # Parse common onesixtyone output lines, e.g. '10.0.0.1 public' or '10.0.0.1:161 public'
    for line in out.splitlines():
        parts = line.strip().split()
        if not parts:
            continue
        # community is usually the last token
        candidate = parts[-1]
        # validate candidate: allow common community charset
        if re.match(r'^[A-Za-z0-9_\-]+$', candidate):
            communities.add(candidate)
    return communities

def worker_snmp(hostname, community, oid, bulkwalk, timeout, dry_run=False):
    # sanitize oid for filename
    oid_filename = oid.replace('::', '--').replace('.', '_').replace(' ', '')
    output_file = f"{hostname}-SNMP-{community}-{oid_filename}.txt"
    # choose command
    if bulkwalk:
        cmd = ["snmpbulkwalk", "-v2c", "-c", community, "-Cr50", "-Cn0", hostname, oid]
    else:
        cmd = ["snmpwalk", "-t", str(timeout), "-Oa", "-v2c", "-c", community, hostname, oid]
    if dry_run:
        print(f"Would run: {' '.join(shlex.quote(p) for p in cmd)} > {output_file}")
        return
    with open(output_file, 'w') as fh:
        try:
            subprocess.run(cmd, stdout=fh, stderr=subprocess.DEVNULL, check=False)
        except FileNotFoundError:
            print(f"Missing tool for command: {cmd[0]}")
    print(f"Finished {community} {oid} -> {output_file}")

def main():
    parser = argparse.ArgumentParser(description="Discover SNMP communities then enumerate OIDs.")
    parser.add_argument("hostname", help="Hostname or IP address")
    parser.add_argument("--wordlist", default="/usr/share/seclists/Discovery/SNMP/snmp-onesixtyone.txt", help="Wordlist for onesixtyone")
    parser.add_argument("--bulkwalk", action="store_true", help="Use snmpbulkwalk for enumeration")
    parser.add_argument("--timeout", type=int, default=10, help="Timeout for snmpwalk")
    parser.add_argument("--oids", nargs="*", default=["NET-SNMP-EXTEND-MIB::nsExtendObjects", ".1"], help="OIDs to query (default: extend + .1)")
    parser.add_argument("--threads", type=int, default=10, help="Max concurrent threads")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without executing")
    args = parser.parse_args()

    # 1) Discover communities with onesixtyone
    print(f"Scanning {args.hostname} for communities using {args.wordlist}...")
    communities = run_onesixtyone(args.hostname, args.wordlist, dry_run=args.dry_run)
    if not communities:
        print("No communities discovered via onesixtyone. Trying fallback: 'public' and 'private'.")
        communities = {"public", "private"}

    print(f"Found communities: {', '.join(sorted(communities))}")

    # 2) For each community, enumerate OIDs (multithreaded)
    threads = []
    sem = threading.BoundedSemaphore(args.threads)

    def thread_target(hostname, community, oid):
        with sem:
            worker_snmp(hostname, community, oid, args.bulkwalk, args.timeout, dry_run=args.dry_run)

    for community in communities:
        for oid in args.oids:
            t = threading.Thread(target=thread_target, args=(args.hostname, community, oid))
            threads.append(t)
            t.start()

    for t in threads:
        t.join()

if __name__ == "__main__":
    main()
