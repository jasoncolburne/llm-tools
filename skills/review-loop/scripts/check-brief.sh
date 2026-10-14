#!/usr/bin/env bash
# check-brief.sh — refuse a brief that still has template holes. Exit 0 only if every file passes.
#
#   check-brief.sh BRIEF...
#
# A brief handed to a reviewer is never edited in place, so a hole found after launch costs a
# versioned re-issue. Checks: no {{placeholder}}, no TODO(brief), the findings path and the final
# marker are named, and (for a cold brief) it names the files to read and says to open nothing else.

set -u
[ $# -ge 1 ] || { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }
rc=0
for f in "$@"; do
  [ -f "$f" ] || { echo "check-brief: $f does not exist" >&2; rc=1; continue; }
  fail=0
  bad=$(grep -n -E '\{\{|TODO\(brief\)' "$f" || true)
  if [ -n "$bad" ]; then echo "FAIL $f — unfilled:"; echo "$bad" | sed 's/^/  /'; fail=1; fi
  grep -q 'findings-' "$f"        || { echo "FAIL $f — names no findings path"; fail=1; }
  grep -q 'REVIEW COMPLETE' "$f"  || { echo "FAIL $f — does not state the final marker"; fail=1; }
  case "$(basename "$f")" in
    *cold*) grep -qi 'open nothing else\|do not open anything else' "$f" \
              || { echo "FAIL $f — a cold brief must say to open nothing else"; fail=1; } ;;
  esac
  if [ $fail = 0 ]; then echo "ok   $f"; else rc=1; fi
done
exit $rc
