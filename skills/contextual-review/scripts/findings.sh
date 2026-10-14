#!/usr/bin/env bash
# findings.sh — the findings-file contract, in one place.
#
#   findings.sh new    FILE TITLE [HEADING...]   create the stub; every heading holds the single line PENDING
#   findings.sh status FILE                      one line: STATE pending=N bytes=B [note=...] age=S
#   findings.sh finish FILE                      append the final marker, only if no PENDING line remains
#
# The contract:
#   - the stub exists before any review work, so a watcher can tell "started" from "never started";
#   - every heading is never empty: it holds content or a line that is exactly PENDING;
#   - the Findings heading is last, so appending a finding lands in its own section;
#   - the file is complete when no whole line is PENDING and its last non-blank line is exactly
#     REVIEW COMPLETE. Nothing is written after that line.
#
# PENDING is counted as a WHOLE LINE only: a heading or sentence that merely contains the word must
# never keep a finished file looking unfinished (it has, once).
#
# status exit codes: 0 COMPLETE, 1 IN_PROGRESS, 2 MISSING.

set -u
MARK='REVIEW COMPLETE'

usage() { sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }

mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1"; }   # GNU first, then BSD/macOS

pending_count() { grep -c '^PENDING[[:space:]]*$' "$1" || true; }

last_line() {
  local l
  l=$(grep -v '^[[:space:]]*$' "$1" | tail -n 1)
  printf '%s' "${l%"${l##*[![:space:]]}"}"
}

cmd=${1:-}
[ $# -gt 0 ] && shift
case "$cmd" in
  new)
    [ $# -ge 2 ] || usage
    f=$1; title=$2; shift 2
    if [ -e "$f" ]; then echo "findings.sh: $f already exists — not overwriting" >&2; exit 1; fi
    mkdir -p "$(dirname "$f")"
    if [ $# -eq 0 ]; then set -- "Disposition" "Verdict per check" "Coverage, method, and where I am unsure"; fi
    {
      printf '# %s\n\n' "$title"
      for h in "$@"; do
        [ "$(printf '%s' "$h" | tr '[:upper:]' '[:lower:]')" = "findings" ] && continue
        printf '## %s\n\nPENDING\n\n' "$h"
      done
      printf '## Findings\n\nPENDING\n'
    } > "$f"
    echo "created $f"
    ;;

  status)
    [ $# -eq 1 ] || usage
    f=$1
    if [ ! -f "$f" ]; then echo "MISSING pending=0 bytes=0 age=0"; exit 2; fi
    pend=$(pending_count "$f")
    bytes=$(wc -c < "$f" | tr -d ' ')
    age=$(( $(date +%s) - $(mtime "$f") ))
    last=$(last_line "$f")
    if [ "$pend" = "0" ] && [ "$last" = "$MARK" ]; then
      echo "COMPLETE pending=0 bytes=$bytes age=$age"; exit 0
    fi
    note=""
    [ "$last" = "$MARK" ] && note=" note=marker-with-pending"
    echo "IN_PROGRESS pending=$pend bytes=$bytes$note age=$age"; exit 1
    ;;

  finish)
    [ $# -eq 1 ] || usage
    f=$1
    [ -f "$f" ] || { echo "findings.sh: $f does not exist" >&2; exit 2; }
    pend=$(pending_count "$f")
    if [ "$pend" != "0" ]; then
      echo "findings.sh: $pend PENDING heading(s) remain — not finishing:" >&2
      awk '/^#+ /{h=$0} /^PENDING[ \t]*$/{print "  line " NR ": under " h}' "$f" >&2
      exit 1
    fi
    if [ "$(last_line "$f")" = "$MARK" ]; then echo "$f is already complete"; exit 0; fi
    [ -n "$(tail -c 1 "$f")" ] && printf '\n' >> "$f"
    printf '%s\n' "$MARK" >> "$f"
    echo "marked complete: $f"
    ;;

  *) usage ;;
esac
