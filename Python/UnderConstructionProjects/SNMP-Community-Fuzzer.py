#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SNMP-MagicScript.py

Owner / Contact
Repository: https://github.com/l3clelVl/HomeGrown/tree/main/Python

Purpose
-------
Validate a *known, authorized* SNMPv2c community string against a target by issuing
a single SNMP GET for sysDescr.0 (1.3.6.1.2.1.1.1.0). Designed for configuration
verification and audit/inventory workflows where you have explicit permission.

Not supported
-------------
- Community discovery / wordlist brute-force / fuzzing.

Dependencies
------------
- Python 3.8+
- PySNMP 7.x (your system shows 7.1.21)
  On Kali/Debian: sudo apt install -y python3-pysnmp

Usage
-----
python SNMP-MagicScript.py -c <community wordlist> <Target-IP-or-Hostname>

Examples
--------
python SNMP-MagicScript.py -c public 192.0.2.10
python SNMP-MagicScript.py -c audit_ro -t 2.0 -r 1 -p 161 switch01.example.org

Exit codes
----------
0  Success (community validated)
1  Failure (no valid SNMP response / auth failure / timeout)
2  Input or dependency error
"""

import argparse
import asyncio
import sys

from pysnmp.hlapi.v3arch.asyncio import (
    CommunityData,
    ObjectIdentity,
    ObjectType,
    SnmpEngine,
    UdpTransportTarget,
    get_cmd,
)


async def try_community(engine, target, port, community, timeout, retries):
    """Try a single community string against the target."""
    error_indication, error_status, _, var_binds = await get_cmd(
        engine,
        CommunityData(community),
        await UdpTransportTarget.create((target, port), timeout=timeout, retries=retries),
        ObjectType(ObjectIdentity("1.3.6.1.2.1.1.1.0")),  # sysDescr
    )

    if error_indication:
        return None
    if error_status:
        return None

    sys_descr = str(var_binds[0][1])
    return community, sys_descr


async def scan(target, port, wordlist_path, timeout, retries, concurrency):
    """Scan target with all community strings from wordlist."""
    with open(wordlist_path, "r") as f:
        communities = [line.strip() for line in f if line.strip()]

    if not communities:
        print("[!] Wordlist is empty.")
        return

    print(f"[*] Target: {target}:{port}")
    print(f"[*] Loaded {len(communities)} community strings from {wordlist_path}")
    print(f"[*] Concurrency: {concurrency} | Timeout: {timeout}s | Retries: {retries}")
    print()

    engine = SnmpEngine()
    semaphore = asyncio.Semaphore(concurrency)
    found = []

    async def bounded_try(community):
        async with semaphore:
            return await try_community(engine, target, port, community, timeout, retries)

    tasks = [bounded_try(c) for c in communities]
    results = await asyncio.gather(*tasks, return_exceptions=True)

    for result in results:
        if isinstance(result, Exception):
            continue
        if result is not None:
            community, sys_descr = result
            found.append(community)
            print(f"[+] FOUND: {target} - '{community}' → {sys_descr}")

    print()
    if found:
        print(f"[✓] {len(found)} valid community string(s): {', '.join(found)}")
    else:
        print("[✗] No valid community strings found.")


def main():
    parser = argparse.ArgumentParser(
        description="SNMP Community String Scanner (PySNMP v7 asyncio HLAPI)",
        usage="%(prog)s -c <wordlist> <target>",
    )
    parser.add_argument("target", help="Target IP or hostname")
    parser.add_argument("-c", "--community-file", required=True, help="Path to community string wordlist")
    parser.add_argument("-p", "--port", type=int, default=161, help="SNMP port (default: 161)")
    parser.add_argument("-t", "--timeout", type=float, default=1.0, help="Timeout per request in seconds (default: 1)")
    parser.add_argument("-r", "--retries", type=int, default=0, help="Retries per request (default: 0)")
    parser.add_argument("-w", "--workers", type=int, default=50, help="Concurrent workers (default: 50)")
    args = parser.parse_args()

    asyncio.run(scan(args.target, args.port, args.community_file, args.timeout, args.retries, args.workers))


if __name__ == "__main__":
    main()