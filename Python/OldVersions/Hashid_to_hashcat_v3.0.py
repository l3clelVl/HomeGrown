#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# =============================================================================
# Hashid to Hashcat v3.0
# CAO: Apr26
# Origin: Aug25
# =============================================================================
# DESCRIPTION:
#   Automated hash identification and cracking pipeline.
#   For one or more hashes (single input or file), the script:
#     1. Identifies candidate hash types via `hashid`
#     2. Resolves corresponding hashcat mode(s) from `hashcat --help`
#     3. Runs hashcat (attack mode 0 — dictionary) against each resolved mode
#     4. Streams cracked results live to stdout as they appear
#
# DEPENDENCIES:
#   - hashid       (pip install hashid)
#   - hashcat      (system install)
#
# USAGE:
#   Interactive:      python3 hash-autocrack.py
#   Pass hash(es):    python3 hash-autocrack.py <hash1> <hash2> ...
#
# INPUT MODES (interactive):
#   1 — Single hash pasted at prompt
#   2 — Path to file containing one hash per line (# = comment/skip)
#
# ATTACK MODES (prompted at runtime):
#   0 — Straight       (-a 0)  wordlist [+ optional rule]
#                               e.g. rockyou.txt [best64.rule]
#   1 — Combinator     (-a 1)  wordlist1 + wordlist2 concatenated
#                               e.g. rockyou.txt + rockyou.txt -> 'password'
#   3 — Brute-force    (-a 3)  mask only, no wordlist
#                               e.g. ?u?l?l?l?d?d
#   6 — Hybrid W+M     (-a 6)  wordlist word with mask appended
#                               e.g. 'password' + '?d?d' -> 'password42'
#   7 — Hybrid M+W     (-a 7)  mask prepended to wordlist word
#                               e.g. '?d?d' + 'password' -> '42password'
#   9 — Association    (-a 9)  candidates derived from username per hash
#                               requires username:hash input format
#                               [+ optional rule]
#
# MASK INPUT (modes 3, 6, 7):
#   Accepts either a literal mask string or a path to an .hcmask file
#   Charsets: ?l=lowercase  ?u=uppercase  ?d=digit  ?s=special  ?a=all  ?b=binary
#   e.g. ?u?l?l?l?d?d   or   /usr/share/hashcat/masks/rockyou-1-60.hcmask
#
# CONFIGURATION (top-level constants):
#   STOP_ON_FIRST_FOR_HASH  — Stop trying further modes once a hash is cracked
#   STATUS_TIMER            — Hashcat status update interval in seconds
#
# RUNTIME CONTROLS:
#   SPACEBAR — Print live hashcat status block for current mode mid-run
#
# OUTPUT:
#   Cracked hashes printed as:  <hash>:<plaintext>  (mode <N>)
#   Full command printed before execution for transparency/reproducibility
#   Hex-encoded plaintexts are automatically decoded to UTF-8
#
# NOTES:
#   - Tab completion available for all file path prompts
#   - Potfile disabled per run (--potfile-disable) — no persistent cache
#   - Deduplicates hash modes before cracking to avoid redundant runs
#   - Temporary output files cleaned up automatically after each run
#   - Mode 9 requires hashes supplied in username:hash format
# =============================================================================

import os, re, sys, tempfile, subprocess, threading, time, termios, tty, select, binascii
from collections import defaultdict

STOP_ON_FIRST_FOR_HASH = True
STATUS_TIMER = "5"

HASHID_LINE = re.compile(r'^\[\+\]\s*(.*?)\s*(?:\[Hashcat Mode:\s*([0-9]+)\])?\s*$')
HC_HELP_LINE = re.compile(r'^\s*([0-9]+)\s*\|\s*(.+?)\s*$')

def _dehex(s):
    if re.fullmatch(r'[0-9a-fA-F]{2,}', s) and len(s) % 2 == 0:
        try:
            return binascii.unhexlify(s).decode('utf-8', 'replace')
        except Exception:
            return s
    return s

def _try_enable_readline_completion():
    try:
        import readline
    except Exception:
        try:
            import pyreadline3 as readline
        except Exception:
            return None
    def complete(text, state):
        buf = readline.get_line_buffer()
        line = os.path.expanduser(buf.strip() or ".")
        d = os.path.dirname(line) or "."
        p = os.path.basename(line)
        try: entries = os.listdir(d)
        except Exception: return None
        m = []
        for e in entries:
            if e.startswith(p):
                path = os.path.join(d, e)
                if os.path.isdir(path) and not path.endswith(os.sep): path += os.sep
                m.append(path)
        return m[state] if state < len(m) else None
    try:
        readline.set_completer_delims(" \t\n")
        readline.parse_and_bind("tab: complete")
        readline.set_completer(complete)
    except Exception:
        pass

def run(cmd):
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

def norm_key(s): return re.sub(r'[^A-Za-z0-9]+', ' ', s).strip().lower()

def get_hashcat_modes():
    r = run(["hashcat", "--help"])
    if r.returncode != 0:
        print("ERROR: cannot run 'hashcat --help'.", file=sys.stderr); return {}
    modes = defaultdict(set)
    for line in r.stdout.splitlines():
        m = HC_HELP_LINE.match(line)
        if m:
            mode, name = m.group(1), m.group(2)
            for k in (name, name.lower(), norm_key(name)): modes[k].add(mode)
    return modes

def hashid_candidates(h):
    r = run(["hashid", "-m", h])
    if r.returncode != 0: return None, r.stderr.strip()
    out = []
    for line in r.stdout.splitlines():
        m = HASHID_LINE.match(line)
        if m:
            out.append((m.group(1).strip(), m.group(2) if m.group(2) else None))
    return out, None

def resolve_modes(name, explicit_mode, hc_idx):
    if explicit_mode: return [explicit_mode]
    found = set()
    for k in (name, name.lower(), norm_key(name)): found |= hc_idx.get(k, set())
    if not found:
        t = norm_key(name)
        for k, ms in hc_idx.items():
            if t in k: found |= ms
    return sorted(found, key=int)

def read_hashes_interactive():
    choice = input("Input type [1=single hash, 2=file of hashes]: ").strip()
    if choice == "1":
        h = input("Paste hash: ").strip()
        return [h] if h else []
    elif choice == "2":
        print("Got hashes in a file? (Tab complete available)")
        _try_enable_readline_completion()
        path = os.path.expanduser(input("Path to file: ").strip())
        if not os.path.isfile(path):
            print(f"ERROR: Hashes file not found: {path}", file=sys.stderr); return []
        hashes, seen, out = [], set(), []
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                s = line.strip()
                if s and not s.startswith("#"): hashes.append(s)
        for x in hashes:
            if x not in seen: seen.add(x); out.append(x)
        return out
    else:
        print("ERROR: invalid choice.", file=sys.stderr); return []

def prompt_attack_config():
    _try_enable_readline_completion()
    print("\nAttack mode:")
    print("  0 — Straight      (wordlist [+ optional rule])")
    print("  1 — Combinator    (wordlist1 + wordlist2)")
    print("  3 — Brute-force   (mask only)")
    print("  6 — Hybrid W+M    (wordlist + mask/hcmask appended)")
    print("  7 — Hybrid M+W    (mask/hcmask prepended + wordlist)")
    print("  9 — Association   (username:hash file + wordlist)")
    choice = input("Mode [0/1/3/6/7/9]: ").strip()

    if choice not in ("0", "1", "3", "6", "7", "9"):
        print(f"ERROR: invalid mode '{choice}'.", file=sys.stderr); sys.exit(3)

    wordlist  = None
    wordlist2 = None
    rule      = None
    mask      = None

    def prompt_file(label, example, optional=False):
        tag = " (optional, press Enter to skip)" if optional else ""
        val = input(f"{label}{tag}\n  e.g. {example}\n> ").strip()
        if not val and optional:
            return None
        val = os.path.expanduser(val)
        if not os.path.isfile(val):
            print(f"ERROR: file not found: {val}", file=sys.stderr); sys.exit(3)
        return val

    def prompt_mask(optional=False):
        tag = " (optional, press Enter to skip)" if optional else ""
        print(f"Mask string or path to .hcmask file{tag}")
        print("  e.g. ?u?l?l?l?d?d   or   /usr/share/hashcat/masks/rockyou-1-60.hcmask")
        raw = input("> ").strip()
        if not raw:
            if optional: return None
            print("ERROR: mask cannot be empty.", file=sys.stderr); sys.exit(3)
        expanded = os.path.expanduser(raw)
        if os.path.isfile(expanded):
            if not expanded.endswith(".hcmask"):
                print(f"WARNING: file lacks .hcmask extension, proceeding: {expanded}")
            return expanded
        if not re.search(r'\?[ludasb\d]', raw, re.IGNORECASE):
            print(f"WARNING: '{raw}' has no recognisable hashcat placeholders (?l ?u ?d ?a ?s ?b)")
        return raw

    if choice == "0":
        print("\n-- Mode 0: Straight --")
        print("Tries each word in the wordlist as-is, optionally mutated by a rule file.")
        wordlist = prompt_file("Wordlist path", "/usr/share/wordlists/rockyou.txt")
        rule     = prompt_file("Rule file path", "/usr/share/hashcat/rules/best64.rule", optional=True)

    elif choice == "1":
        print("\n-- Mode 1: Combinator --")
        print("Concatenates every word from list1 with every word from list2.")
        print("  e.g. 'pass' + 'word' -> 'password'")
        wordlist  = prompt_file("Wordlist 1 path", "/usr/share/wordlists/rockyou.txt")
        wordlist2 = prompt_file("Wordlist 2 path", "/usr/share/wordlists/rockyou.txt")

    elif choice == "3":
        print("\n-- Mode 3: Brute-force --")
        print("Exhausts every combination within the mask keyspace. No wordlist needed.")
        print("  Charsets: ?l=lowercase  ?u=uppercase  ?d=digit  ?s=special  ?a=all  ?b=binary")
        mask = prompt_mask()

    elif choice == "6":
        print("\n-- Mode 6: Hybrid wordlist + mask --")
        print("Appends mask candidates to each wordlist word.")
        print("  e.g. 'password' + '?d?d' -> 'password42'")
        wordlist = prompt_file("Wordlist path", "/usr/share/wordlists/rockyou.txt")
        mask     = prompt_mask()

    elif choice == "7":
        print("\n-- Mode 7: Hybrid mask + wordlist --")
        print("Prepends mask candidates to each wordlist word.")
        print("  e.g. '?d?d' + 'password' -> '42password'")
        mask     = prompt_mask()
        wordlist = prompt_file("Wordlist path", "/usr/share/wordlists/rockyou.txt")

    elif choice == "9":
        print("\n-- Mode 9: Association --")
        print("Generates candidates from the username associated with each hash.")
        print("  Requires input file in username:hash format.")
        print("  e.g. admin:5f4dcc3b5aa765d61d8327deb882cf99")
        wordlist = prompt_file("Wordlist path", "/usr/share/wordlists/rockyou.txt")
        rule     = prompt_file("Rule file path", "/usr/share/hashcat/rules/best64.rule", optional=True)

    return choice, wordlist, wordlist2, rule, mask


class SpacebarWatcher:
    def __init__(self): self._orig=None; self._enabled=False
    def __enter__(self):
        if not sys.stdin.isatty(): return self
        self._orig = termios.tcgetattr(sys.stdin.fileno())
        tty.setcbreak(sys.stdin.fileno())
        self._enabled=True
        return self
    def __exit__(self, *_):
        if self._enabled and self._orig: termios.tcsetattr(sys.stdin.fileno(), termios.TCSADRAIN, self._orig)
        self._enabled=False
    def space_pressed(self, timeout=0.05):
        if not self._enabled: time.sleep(timeout); return False
        r,_,_ = select.select([sys.stdin], [], [], timeout)
        if r:
            ch = sys.stdin.read(1)
            return ch == " "
        return False


def run_hashcat_try(hash_str, hc_mode, hc_attack, wordlist, wordlist2, rule, mask, outfile, status_buf_lock, status_buf):
    cmd = [
        "hashcat",
        "-a", hc_attack,
        "-m", str(hc_mode),
        "--quiet",
        "--status", f"--status-timer={STATUS_TIMER}",
        "--potfile-disable",
        "--outfile", outfile,
        "--outfile-format", "3",
        "--outfile-autohex-disable",
    ]

    if rule:
        cmd += ["-r", rule]

    # positional args vary by attack mode
    cmd.append(hash_str)

    if hc_attack == "0":                        # straight
        cmd.append(wordlist)

    elif hc_attack == "1":                      # combinator
        cmd += [wordlist, wordlist2]

    elif hc_attack == "3":                      # brute-force
        cmd.append(mask)

    elif hc_attack == "6":                      # hybrid W+M
        cmd += [wordlist, mask]

    elif hc_attack == "7":                      # hybrid M+W
        cmd += [mask, wordlist]

    elif hc_attack == "9":                      # association
        cmd.append(wordlist)

    import shlex
    print(f"\n# running: {shlex.join(cmd)}\n")

    proc = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, bufsize=1
    )


    def reader():
        block = []
        for line in proc.stdout:
            block.append(line.rstrip("\n"))
            if line.strip() == "":
                with status_buf_lock:
                    status_buf[:] = block[-40:]
        proc.stdout.close()

    t = threading.Thread(target=reader, daemon=True)
    t.start()

    with SpacebarWatcher() as sw:
        seen_lines = set()
        while proc.poll() is None:
            if sw.space_pressed(0.1):
                try: proc.stdin.write("s"); proc.stdin.flush()
                except Exception: pass
                with status_buf_lock:
                    if status_buf:
                        print(f"\n--- status: hash mode {hc_mode} ---")
                        for ln in status_buf: print(ln)
                        print("--- end status ---\n")
            if os.path.exists(outfile):
                with open(outfile, "r", encoding="utf-8", errors="ignore") as f:
                    for ln in f:
                        ln = ln.rstrip("\n")
                        if ln and ln not in seen_lines:
                            parts = ln.split(":")
                            pwd = parts[-1]
                            plain = _dehex(pwd)
                            print(f"{':'.join(parts[:-1])}:{plain}  (mode {hc_mode})")
                            seen_lines.add(ln)
            time.sleep(0.2)

    t.join(timeout=0.5)
    return bool(seen_lines)


def main():
    if run(["hashid", "-h"]).returncode not in (0, 1):
        print("ERROR: 'hashid' not found.", file=sys.stderr); sys.exit(2)
    if run(["hashcat", "--version"]).returncode != 0:
        print("ERROR: 'hashcat' not found.", file=sys.stderr); sys.exit(2)

    hashes = [h for h in sys.argv[1:] if h.strip()] if len(sys.argv) > 1 else read_hashes_interactive()
    if not hashes: print("No hashes to process.", file=sys.stderr); sys.exit(1)

    # Single prompt for attack config covers wordlist + optional rule/mask
    hc_attack, wordlist, wordlist2, rule, mask = prompt_attack_config()

    hc_idx = get_hashcat_modes()

    with tempfile.TemporaryDirectory(prefix="hc_runs_") as td:
        for h in hashes:
            cands, err = hashid_candidates(h)
            if err:
                print(f"# ERROR for {h}: {err}", file=sys.stderr); continue
            if not cands:
                print(f"# No candidates: {h}"); continue

            modes = []
            for name, explicit in cands:
                modes.extend(resolve_modes(name, explicit, hc_idx))

            seen = set()
            deduped = []
            for m in modes:
                if m not in seen: seen.add(m); deduped.append(m)
            modes = deduped

            if not modes:
                print(f"# No modes resolved: {h}"); continue

            print(f"# trying modes for {h}: {','.join(modes)}")

            found = False
            for m in modes:
                outfile = os.path.join(td, f"found_m{m}.txt")
                status_buf, status_buf_lock = [], threading.Lock()
                if run_hashcat_try(h, m, hc_attack, wordlist, wordlist2, rule, mask, outfile, status_buf_lock, status_buf):
                    found = True
                    if STOP_ON_FIRST_FOR_HASH:
                        break


if __name__ == "__main__":
    main()