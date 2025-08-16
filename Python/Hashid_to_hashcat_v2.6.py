#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, re, sys, tempfile, subprocess, threading, time, termios, tty, select, binascii
from collections import defaultdict

STOP_ON_FIRST_FOR_HASH = True
ATTACK_MODE = "0"
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
            import pyreadline3 as readline  # windows
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

def prompt_wordlist_once():
    print("Got a password list to play with? (Tab complete is still available)")
    _try_enable_readline_completion()
    wl = os.path.expanduser(input("Path to pass/wordlist: ").strip())
    if not os.path.isfile(wl):
        print(f"ERROR: pass/wordlist not found: {wl}", file=sys.stderr); sys.exit(3)
    return wl

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
        

def run_hashcat_try(hash_str, mode, wordlist, outfile, status_buf_lock, status_buf):
    proc = subprocess.Popen(
        ["hashcat","-a",ATTACK_MODE,"-m",str(mode),hash_str,wordlist,
         "--quiet","--status",f"--status-timer={STATUS_TIMER}",
         "--potfile-disable","--outfile",outfile,"--outfile-format","3",
         "--outfile-autohex-disable"],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1
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
        # tail outfile live
        seen_lines = set()
        while proc.poll() is None:
            if sw.space_pressed(0.1):
                try: proc.stdin.write("s"); proc.stdin.flush()
                except Exception: pass
                with status_buf_lock:
                    if status_buf:
                        print(f"\n--- status: hash mode {mode} ---")
                        for ln in status_buf: print(ln)
                        print("--- end status ---\n")
            # echo any new cracks immediately
            if os.path.exists(outfile):
                with open(outfile, "r", encoding="utf-8", errors="ignore") as f:
                    for ln in f:
                        ln = ln.rstrip("\n")
                        if ln and ln not in seen_lines:
                            parts = ln.split(":")
                            pwd = parts[-1]
                            plain = _dehex(pwd)
                            print(f"{':'.join(parts[:-1])}:{plain}  (mode {mode})")

                            seen_lines.add(ln)
            time.sleep(0.2)

    t.join(timeout=0.5)
    # return True if we printed any cracks for this mode
    return bool(seen_lines)


def main():
    if run(["hashid","-h"]).returncode not in (0,1):
        print("ERROR: 'hashid' not found.", file=sys.stderr); sys.exit(2)
    if run(["hashcat","--version"]).returncode != 0:
        print("ERROR: 'hashcat' not found.", file=sys.stderr); sys.exit(2)

    hashes = [h for h in sys.argv[1:] if h.strip()] if len(sys.argv)>1 else read_hashes_interactive()
    if not hashes: print("No hashes to process.", file=sys.stderr); sys.exit(1)
    wordlist = prompt_wordlist_once()

    hc_idx = get_hashcat_modes()

    with tempfile.TemporaryDirectory(prefix="hc_runs_") as td:
        for h in hashes:
            cands, err = hashid_candidates(h)
            if err:
                print(f"# ERROR for {h}: {err}", file=sys.stderr)
                continue
            if not cands:
                print(f"# No candidates: {h}")
                continue
        
            # collect modes
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
        
            # Patch 2: show what will run
            print(f"# trying modes for {h}: {','.join(modes)}")
        
            found = False
            for m in modes:
                outfile = os.path.join(td, f"found_m{m}.txt")
                status_buf, status_buf_lock = [], threading.Lock()
                if run_hashcat_try(h, m, wordlist, outfile, status_buf_lock, status_buf):
                    found = True
                    if STOP_ON_FIRST_FOR_HASH:
                        break
            # silent if not found


if __name__ == "__main__":
    main()
