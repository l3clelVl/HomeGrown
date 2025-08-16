#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
import sys
import tempfile
import subprocess
from collections import defaultdict

# -------- config toggles --------
STOP_ON_FIRST_FOR_HASH = True   # stop trying other modes for a hash once cracked
ATTACK_MODE = "0"               # default attack (-a). 0 = straight wordlist
STATUS_TIMER = "5"              # seconds between status updates (mute anyway)

# -------- optional readline for tab completion --------
def _try_enable_readline_completion():
    try:
        import readline
    except Exception:
        try:
            import pyreadline3 as readline  # Windows
        except Exception:
            return None

    def complete(text, state):
        buf = readline.get_line_buffer()
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
        import readline  # noqa: F401  (already imported above if present)
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
    import re as _re
    return _re.sub(r'[^A-Za-z0-9]+', ' ', s).strip().lower()

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
        seen, uniq = set(), []
        for x in hashes:
            if x not in seen:
                seen.add(x)
                uniq.append(x)
        return uniq
    else:
        print("ERROR: invalid choice. Use 1 or 2.", file=sys.stderr)
        return []

def prompt_wordlist():
    print("(Tab completion enabled for file path if available)")
    _try_enable_readline_completion()
    p = input("Path to wordlist: ").strip()
    p = os.path.expanduser(p)
    if not os.path.isfile(p):
        print(f"ERROR: wordlist not found: {p}", file=sys.stderr)
        sys.exit(3)
    return p

# -------- hashcat runner --------
def run_hashcat_try(hash_str, mode, wordlist, outfile):
    """
    Run hashcat once for the given mode.
    Writes cracked credentials to 'outfile' in format 'hash:plain'.
    Returns True if the target hash was cracked, else False.
    """
    # Use potfile-disable so results are confined to outfile.
    cmd = [
        "hashcat",
        "-a", ATTACK_MODE,
        "-m", str(mode),
        hash_str,
        wordlist,
        "--quiet",
        "--status",
        f"--status-timer={STATUS_TIMER}",
        "--potfile-disable",
        "--outfile", outfile,
        "--outfile-format", "3",
    ]
    r = run(cmd)

    if r.returncode not in (0, 1, 2, 255):
        # hashcat non-standard error
        return False

    # Parse outfile: hash may contain colons; password is last field
    if not os.path.exists(outfile):
        return False

    cracked = False
    with open(outfile, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.rstrip("\n")
            if not line:
                continue
            parts = line.split(":")
            if len(parts) < 2:
                continue
            pwd = parts[-1]
            recovered_hash = ":".join(parts[:-1])
            if recovered_hash == hash_str:
                print(f"{hash_str}:{pwd}  (mode {mode})")
                cracked = True
    return cracked

def main():
    # Dependencies
    if run(["hashid", "-h"]).returncode not in (0, 1):
        print("ERROR: 'hashid' not found.", file=sys.stderr)
        sys.exit(2)
    if run(["hashcat", "--version"]).returncode != 0:
        print("ERROR: 'hashcat' not found.", file=sys.stderr)
        sys.exit(2)

    # Input
    hashes = [h for h in sys.argv[1:] if h.strip()] if len(sys.argv) > 1 else read_hashes_interactive()
    if not hashes:
        print("No hashes to process.", file=sys.stderr)
        sys.exit(1)
    wordlist = prompt_wordlist()

    hc_idx = get_hashcat_modes()

    # Work temp dir for outfiles
    with tempfile.TemporaryDirectory(prefix="hc_runs_") as td:
        for h in hashes:
            cands, err = hashid_candidates(h)
            if err:
                print(f"# ERROR for {h}: {err}", file=sys.stderr)
                continue
            if not cands:
                print(f"# No candidates: {h}")
                continue

            # all candidate modes
            modes = []
            for name, explicit in cands:
                modes.extend(resolve_modes(name, explicit, hc_idx))

            # de-dup preserve order
            seen = set()
            deduped = []
            for m in modes:
                if m not in seen:
                    seen.add(m)
                    deduped.append(m)
            modes = deduped

            if not modes:
                print(f"# No modes resolved: {h}")
                continue

            found = False
            for m in modes:
                outfile = os.path.join(td, f"found_m{m}.txt")
                if run_hashcat_try(h, m, wordlist, outfile):
                    found = True
                    if STOP_ON_FIRST_FOR_HASH:
                        break
            if not found:
                # remain silent by design; uncomment next line if you want negatives
                # print(f"# Not cracked: {h}")
                pass

if __name__ == "__main__":
    main()
