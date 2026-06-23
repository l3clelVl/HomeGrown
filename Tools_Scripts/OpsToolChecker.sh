#!/usr/bin/env bash
# OpsToolChecker.sh — fast "do I have it?" presence check from a token list
set -euo pipefail

usage() {
  cat <<'EOF'
OpsToolChecker.sh — fast presence check from a token list (no hashing by default)

USAGE
  ./OpsToolChecker.sh [OPTIONS] [LISTFILE]
  ./OpsToolChecker.sh -h | --help

ARGUMENTS
  LISTFILE   Tokens, one per line (default: ListOfTools.txt). '#' = comment.
             Greppable tokens, not display names (PowerView, secretsdump, …).

OPTIONS
  -v, --verbose  List every matching path (default: count + first path only).
  -m, --md5      md5sum the first match per tool — reads file bytes (opt-in).
  -u, --update   sudo updatedb before checking (locate mode).
  -F, --find     Force a find walk instead of the locate DB.
  -h, --help     Show this help and exit.

INDEXING
  Primary: locate/plocate DB — indexed lookup per token, metadata only, ~0 IO.
  Fallback: one find / pass (only if locate is absent/empty or -F given).

OUTPUT
  [ OK ] token (n) -> first/path     |     [MISS] token
  md5 and full path lists are OFF by default. Timestamped report written too.
EOF
}

VERBOSE=0; DOMD5=0; UPDATE=0; FORCE_FIND=0; LIST=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)    usage; exit 0 ;;
    -v|--verbose) VERBOSE=1; shift ;;
    -m|--md5)     DOMD5=1; shift ;;
    -u|--update)  UPDATE=1; shift ;;
    -F|--find)    FORCE_FIND=1; shift ;;
    -*)           echo "[!] Unknown option: $1" >&2; echo >&2; usage >&2; exit 2 ;;
    *)            LIST="$1"; shift ;;
  esac
done
LIST="${LIST:-ListOfTools.txt}"
[ -f "$LIST" ] || { echo "[!] List file not found: $LIST" >&2; echo >&2; usage >&2; exit 1; }

REPORT="toolschecked_$(date +%F_%H%M).log"; : > "$REPORT"
[ "$UPDATE" -eq 1 ] && { echo "[*] updatedb…" >&2; sudo updatedb 2>/dev/null || updatedb 2>/dev/null || echo "[!] updatedb failed." >&2; }

MODE=find; INDEX=""
if [ "$FORCE_FIND" -eq 0 ] && command -v locate >/dev/null 2>&1 && locate -l1 -- / >/dev/null 2>&1; then
  MODE=locate
else
  INDEX="$(mktemp)"; trap 'rm -f "$INDEX"' EXIT
  echo "[*] Building find index (one pass)…" >&2
  find / \( -path /proc -o -path /sys -o -path /dev -o -path /run \) -prune \
       -o -type f -print 2>/dev/null > "$INDEX" || true
fi
echo "[*] Backend: $MODE" >&2

search() {  # emit matching paths for token $1
  if [ "$MODE" = locate ]; then locate -i -- "$1" 2>/dev/null
  else grep -iF -- "$1" "$INDEX" 2>/dev/null; fi
}

found=0; missing=0
while IFS= read -r line || [ -n "$line" ]; do
  pat="$(printf '%s' "$line" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  [ -z "$pat" ] && continue
  mapfile -t hits < <(search "$pat" || true)
  n=${#hits[@]}
  if [ "$n" -eq 0 ]; then
    printf '[MISS] %s\n' "$pat" | tee -a "$REPORT"; missing=$((missing+1)); continue
  fi
  found=$((found+1)); first="${hits[0]}"
  if [ "$DOMD5" -eq 1 ]; then
    printf '[ OK ] %-18s (%d) -> %s  [%s]\n' "$pat" "$n" "$first" "$(md5sum -- "$first" 2>/dev/null | cut -d' ' -f1)" | tee -a "$REPORT"
  else
    printf '[ OK ] %-18s (%d) -> %s\n' "$pat" "$n" "$first" | tee -a "$REPORT"
  fi
  [ "$VERBOSE" -eq 1 ] && for f in "${hits[@]:1}"; do printf '%26s%s\n' '' "$f" | tee -a "$REPORT"; done
done < "$LIST"

printf '\n[*] %d present, %d missing  ->  %s\n' "$found" "$missing" "$REPORT" | tee -a "$REPORT"
printf '[*] Download queue:\n'; grep '^\[MISS\]' "$REPORT" | sed 's/^\[MISS\] //' || true
