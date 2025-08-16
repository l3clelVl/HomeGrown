#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
import sys
import subprocess
from collections import defaultdict

# -------- optional readline for tab completion --------
def _try_enable_readline_completion():
    try:
        import readline  # Linux/macOS
    except Exception:
        try:
            import pyreadline3 as readline  # Windows
        except Exception:
            return None

    def complete(text, state):
        buf = readline.get_line_buffer()
        # if user started typing a path, use that; else default to current dir
        line = buf.strip() or "."
        line = os.path.expanduser(line)
        dirname = os.path.dirname(line) or "."
        prefix = os.path.basename(line)
        try:
            entries = os.listdir(dirname)
        except Exception:
            return None
        matches = [e for e in entries if e.startswith(prefix)]
        out = []
        for m in matches:
            p = os.path.join(dirname, m)
            if os.path.isdir(p) and not p.endswith(os.sep):
                p = p + os.sep
            out.append(p)
        return out[state] if state < len(out) else None

    try:
        readline.set_completer_delims(" \t\n")
        readline.parse_and_bind("tab: complete")
        readline.set_completer(complete)
        return True
    except Exception:
        return None

# -------- regex patterns --------
HASHID_LINE = re.compile(r'^\[\+\]\s*(.*?)\s*(?:\[Hashcat Mode:\s*([0-9]+)\])?\s*$')
HC_HELP_LINE = re.compile(r'^\s*([0-9]+)\s*\|\s*(.+?)\s*$')

# -------- subprocess helper --------
def run(cmd):
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

# -------- normalization --------
def norm_key(s: str) -> str:
    return re.sub(r'[^A-Za-z0-9]+', ' ', s).strip().lower()

# -------- build hashcat help index --------
def get_hashcat_modes():
    r = run(["hashcat", "--help"])
    if r.returncode != 0:
        print("ERROR: cannot run 'hashcat --help'. Is hashcat installed and on PATH?", file=sys.stderr)
        return {}
    modes = defaultdict(set)
    for line in r.stdout.splitlines():
        m = HC_HELP_LINE.match(line)
        if not m:
            continue
        mode, name = m.group(1), m.group(2)
        keys = {name, name.lower(), norm_key(name)}
        for k in keys:
            modes[k].add(mode)
    return modes

# -------- query hashid for candidates --------
def hashid_candidates(h):
    r = run(["hashid", "-m", h])
    if r.returncode != 0:
        return None, r.stderr.strip()
    out = []
    for line in r.stdout.splitlines():
        m = HASHID_LINE.match(line)
        if m:
            name = m.group(1).strip()
            mode = m.group(2) if m.group(2) else None
            out.append((name, mode))
    return out, None

# -------- resolve to mode ids --------
def resolve_modes(name, explicit_mode, hc_idx):
    if explicit_mode:
        return [explicit_mode]
    keys = {name, name.lower(), norm_key(name)}
    found = set()
    for k in keys:
        found |= hc_idx.get(k, set())
    if not found:
        target = norm_key(name)
        for k, modes in hc_idx.items():
            if target in k:
                found |= modes
    return sorted(found, key=int)

# -------- input handling --------
def read_hashes_interactive():
    choice = input("Input type [1=single hash, 2=file of hashes]: ").strip()
    if choice == "1":
        h = input("Paste hash: ").strip()
        return [h] if h else []
    elif choice == "2":
        print("(Tab completion enabled for file path if available)")
        _try_enable_readline_completion()
        path = input("Path to file: ").strip()
        path = os.path.expanduser(path)
        if not os.path.isfile(path):
            print(f"ERROR: file not found: {path}", file=sys.stderr)
            return []
        hashes = []
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                s = line.strip()
                if not s or s.startswith("#"):
                    continue
                hashes.append(s)
        # de-dup preserve order
        seen = set()
        uniq = []
        for x in hashes:
            if x not in seen:
                seen.add(x)
                uniq.append(x)
        return uniq
    else:
        print("ERROR: invalid choice. Use 1 or 2.", file=sys.stderr)
        return []

def main():
    # Non-interactive mode accepts hashes as args
    if len(sys.argv) > 1:
        hashes = [h for h in sys.argv[1:] if h.strip()]
    else:
        hashes = read_hashes_interactive()

    if not hashes:
        print("No hashes to process.", file=sys.stderr)
        sys.exit(1)

    # dependency checks
    chk = run(["hashid", "-h"])
    if chk.returncode not in (0, 1):
        print("ERROR: 'hashid' not found. Install and ensure it is on PATH.", file=sys.stderr)
        sys.exit(2)

    hc_idx = get_hashcat_modes()
    if not hc_idx:
        print("WARNING: hashcat modes index is empty. Results may be incomplete.", file=sys.stderr)

    for h in hashes:
        print(h)
        cands, err = hashid_candidates(h)
        if err:
            print(f"  ERROR: {err}")
            continue
        if not cands:
            print("  No candidates from hashid")
            continue
        for name, mode in cands:
            modes = resolve_modes(name, mode, hc_idx)
            if modes:
                print(f"  {name} -> {','.join(modes)}")
            else:
                print(f"  {name} -> unknown")

if __name__ == "__main__":
    main()
