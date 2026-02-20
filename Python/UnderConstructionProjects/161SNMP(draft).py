"""
# ##########################
# https://github.com/l3clelVl/HomeGrown/blob/main/Python/161SNMP.py
# Author: DeMzDaRulez
# OG = 29Jul23
# v5 = 16Feb26
# Purpose: Lightweight wrapper to run onesixtyone then perform an snmpwalk
#
#
# Purpose:
#  1) Discover SNMP communities (v2c) using onesixtyone semantics.
#  2) If a community is found, perform a bulk walk (GETBULK) of mib-2
#
# Usage:
#  python 161SNMP.py <Target-IP-or-Hostname>
#
# Notes: 
#       - Pure Python SNMP community discovery (v2c) + bulk-walk (GETBULK) using pysnmp.
#       - No external tool wrappers.
#       - Designed for quick checks and small engagements, not large-scale scanning.
#       - It writes `snmp_community-backup.txt` in the current working directory, which contains both the discovery results and the bulk walk output.
#       - The community list is loaded from common wordlist paths or falls back to a small embedded list.
#       - The bulk walk output is formatted to approximate snmpbulkwalk's style.
#       - Error handling is included for resolution, probing, and walking steps.
#       - Requires Python 3 and the pysnmp library (`pip install pysnmp`).
#
# ##########################
"""

#!/usr/bin/env python3


import argparse
import os
import socket
import sys
from datetime import datetime
from pathlib import Path
from typing import Iterable, List, Optional, Tuple

from pysnmp.hlapi import (
    SnmpEngine,
    CommunityData,
    UdpTransportTarget,
    ContextData,
    ObjectType,
    ObjectIdentity,
    getCmd,
    bulkCmd,
)
from pysnmp.proto.rfc1902 import (
    OctetString,
    Integer,
    Integer32,
    ObjectName,
    TimeTicks,
    Gauge32,
    Counter32,
    Counter64,
    IpAddress,
    Unsigned32,
)


# ---- Configuration defaults (everything else determined by the script) ----
DEFAULT_PORT = 161
DEFAULT_TIMEOUT = 1.5     # seconds
DEFAULT_RETRIES = 1
PROBE_OID = "1.3.6.1.2.1.1.1.0"      # sysDescr.0
WALK_BASE_OID = "1.3.6.1.2.1"        # mib-2
BULK_MAX_REPS = 25                  # similar feel to snmpbulkwalk


# ---- Community list discovery ----
def candidate_wordlists() -> List[Path]:
    # Common Kali/HTB/SecLists locations + local dir
    return [
        Path.cwd() / "community.txt",
        Path.cwd() / "snmp.txt",
        Path("/usr/share/seclists/Discovery/SNMP/common-snmp-community-strings.txt"),
        Path("/usr/share/seclists/Discovery/SNMP/snmp.txt"),
        Path("/usr/share/wordlists/snmp.txt"),
    ]


def load_communities() -> List[str]:
    # Try to load from known wordlist paths; fallback to embedded common list.
    for p in candidate_wordlists():
        try:
            if p.is_file():
                lines = []
                for line in p.read_text(errors="ignore").splitlines():
                    s = line.strip()
                    if s and not s.startswith("#"):
                        lines.append(s)
                # de-dupe while preserving order
                seen = set()
                out = []
                for s in lines:
                    if s not in seen:
                        out.append(s)
                        seen.add(s)
                if out:
                    return out
        except Exception:
            pass

    # Fallback (small, reasonable default)
    fallback = [
        "public", "private", "cisco", "snmp", "read", "write", "admin",
        "manager", "monitor", "community", "root", "default", "test",
        "public123", "private123",
    ]
    return fallback


# ---- SNMP helpers ----
def resolve_target(target: str) -> str:
    # Keep original hostname, but confirm it resolves for cleaner errors.
    try:
        socket.getaddrinfo(target, None)
        return target
    except socket.gaierror as e:
        raise SystemExit(f"[!] Could not resolve target '{target}': {e}") from e


def snmp_probe_sysdescr(
    target: str,
    community: str,
    port: int,
    timeout: float,
    retries: int,
) -> Tuple[bool, str]:
    """
    Returns (ok, message). ok=True if community works and sysDescr.0 is readable.
    """
    iterator = getCmd(
        SnmpEngine(),
        CommunityData(community, mpModel=1),  # SNMPv2c
        UdpTransportTarget((target, port), timeout=timeout, retries=retries),
        ContextData(),
        ObjectType(ObjectIdentity(PROBE_OID)),
    )

    error_indication, error_status, error_index, var_binds = next(iterator)

    if error_indication:
        # Timeouts / unreachable / etc
        return False, str(error_indication)

    if error_status:
        # authorizationError, noSuchName (v1), etc
        return False, f"{error_status.prettyPrint()} at {error_index}"

    # Success
    for oid, val in var_binds:
        return True, f"{oid.prettyPrint()} = {val.prettyPrint()}"
    return True, "OK"


def is_printable_bytes(b: bytes) -> bool:
    # Consider “printable” close to what net-snmp treats as STRING
    for ch in b:
        if ch in (9, 10, 13):  # tab, lf, cr
            continue
        if ch < 32 or ch > 126:
            return False
    return True


def format_value(val) -> Tuple[str, str]:
    """
    Return (TYPE_LABEL, FORMATTED_VALUE) approximating snmpbulkwalk output.
    """
    # OctetString -> STRING or Hex-STRING
    if isinstance(val, OctetString):
        raw = bytes(val)
        if raw and not is_printable_bytes(raw):
            hex_pairs = " ".join(f"{x:02X}" for x in raw)
            return "Hex-STRING", hex_pairs
        # printable
        return "STRING", f"\"{val.prettyPrint()}\""

    if isinstance(val, (Integer, Integer32, Unsigned32)):
        return "INTEGER", val.prettyPrint()

    if isinstance(val, ObjectName):
        return "OID", val.prettyPrint()

    if isinstance(val, TimeTicks):
        # pysnmp prints raw ticks; net-snmp prints both ticks and human time
        # We'll compute an approximation of d:hh:mm:ss.xx
        ticks = int(val)
        hundredths = ticks % 100
        total_seconds = ticks // 100
        days = total_seconds // 86400
        rem = total_seconds % 86400
        hours = rem // 3600
        rem %= 3600
        minutes = rem // 60
        seconds = rem % 60
        human = f"{days}:{hours:02d}:{minutes:02d}:{seconds:02d}.{hundredths:02d}"
        return "Timeticks", f"({ticks}) {human}"

    if isinstance(val, Gauge32):
        return "Gauge32", val.prettyPrint()

    if isinstance(val, Counter32):
        return "Counter32", val.prettyPrint()

    if isinstance(val, Counter64):
        return "Counter64", val.prettyPrint()

    if isinstance(val, IpAddress):
        return "IpAddress", val.prettyPrint()

    # fallback
    return val.__class__.__name__, val.prettyPrint()


def snmp_bulk_walk(
    target: str,
    community: str,
    base_oid: str,
    port: int,
    timeout: float,
    retries: int,
    max_reps: int,
) -> Iterable[Tuple[str, str, str]]:
    """
    Yields tuples: (oid_str, type_label, value_str)
    """
    engine = SnmpEngine()
    auth = CommunityData(community, mpModel=1)  # v2c
    transport = UdpTransportTarget((target, port), timeout=timeout, retries=retries)
    context = ContextData()

    # lexicographicMode=False stops at end of subtree
    for (error_indication, error_status, error_index, var_binds) in bulkCmd(
        engine,
        auth,
        transport,
        context,
        0,             # nonRepeaters
        max_reps,      # maxRepetitions
        ObjectType(ObjectIdentity(base_oid)),
        lexicographicMode=False,
    ):
        if error_indication:
            raise RuntimeError(str(error_indication))
        if error_status:
            raise RuntimeError(f"{error_status.prettyPrint()} at {error_index}")

        for oid, val in var_binds:
            oid_s = oid.prettyPrint()
            # Extra guard: ensure we stay under base_oid
            if not oid_s.startswith(base_oid + ".") and oid_s != base_oid:
                return
            t, v = format_value(val)
            yield oid_s, t, v


# ---- Output / main ----
def tee_print(line: str, fh):
    print(line)
    fh.write(line + "\n")
    fh.flush()


def main() -> int:
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("target", help="Target IP or hostname")
    args = ap.parse_args()

    target = resolve_target(args.target)

    communities = load_communities()
    out_file = Path.cwd() / "snmp_community-backup.txt"

    found: Optional[str] = None

    with out_file.open("w", encoding="utf-8", errors="ignore") as fh:
        tee_print(f"# SNMP-MagicScript run: {datetime.utcnow().isoformat()}Z", fh)
        tee_print(f"# Target: {target}", fh)
        tee_print(f"# Port: {DEFAULT_PORT}  Timeout: {DEFAULT_TIMEOUT}s  Retries: {DEFAULT_RETRIES}", fh)
        tee_print(f"# Candidates: {len(communities)} communities", fh)
        tee_print("", fh)

        # 1) Community “bruteforce” (probe sysDescr.0)
        for c in communities:
            ok, msg = snmp_probe_sysdescr(
                target=target,
                community=c,
                port=DEFAULT_PORT,
                timeout=DEFAULT_TIMEOUT,
                retries=DEFAULT_RETRIES,
            )
            if ok:
                found = c
                tee_print(f"[+] Community found: {found}", fh)
                tee_print(f"[+] Probe: {msg}", fh)
                tee_print("", fh)
                break

        if not found:
            tee_print("[!] No working community found with available candidates.", fh)
            tee_print("[!] Tip: put a larger list in ./community.txt (one per line).", fh)
            return 2

        # 2) Bulk walk mib-2 (similar to snmpbulkwalk -v2c -c <community> <target>)
        try:
            for oid_s, t, v in snmp_bulk_walk(
                target=target,
                community=found,
                base_oid=WALK_BASE_OID,
                port=DEFAULT_PORT,
                timeout=DEFAULT_TIMEOUT,
                retries=DEFAULT_RETRIES,
                max_reps=BULK_MAX_REPS,
            ):
                # Approximate snmpbulkwalk formatting:
                # <oid> = <TYPE>: <value>
                line = f"{oid_s} = {t}: {v}"
                tee_print(line, fh)
        except Exception as e:
            tee_print(f"[!] Walk error: {e}", fh)
            return 3

    return 0


if __name__ == "__main__":
    sys.exit(main())
