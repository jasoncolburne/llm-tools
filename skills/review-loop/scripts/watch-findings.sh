#!/usr/bin/env bash
# watch-findings.sh — tell the designer when the reviewers' findings files are done.
#
#   watch-findings.sh [--stall-secs N] [--missing-secs N] [--interval N] LABEL=FILE [LABEL=FILE...]
#
# Run it under the Monitor tool: each line it prints is one event. Events:
#   DONE <label>: ...       the file's last line is REVIEW COMPLETE and no PENDING line remains
#   STALLED? <label>: ...   an unfinished file has not been written for --stall-secs (default 2700)
#   MISSING? <label>: ...   no file exists --missing-secs (default 600) after the watch FIRST started
#   ALL DONE — ...          every file is complete; the script exits 0
#
# The first-start time is kept in a stamp file (keyed by the arguments), so a re-armed watch measures
# from the first arming. The stamp is removed when the watch finishes. The Monitor tool caps a run
# (30 minutes here): re-arm with the same command ONLY when an expiry notice arrives.
#
# Completeness is decided by findings.sh status (same directory) — one definition, shared.

set -u
STALL=2700; MISSING=600; INTERVAL=30

usage() { sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --stall-secs)   STALL=$2; shift 2 ;;
    --missing-secs) MISSING=$2; shift 2 ;;
    --interval)     INTERVAL=$2; shift 2 ;;
    -h|--help)      usage ;;
    -*)             echo "watch-findings: unknown option $1" >&2; exit 2 ;;
    *)              break ;;
  esac
done
[ $# -ge 1 ] || usage

HERE=$(cd "$(dirname "$0")" && pwd)
labels=(); files=(); isdone=(); stalled=(); missed=()
for a in "$@"; do
  case "$a" in
    *=*) labels+=("${a%%=*}"); files+=("${a#*=}"); isdone+=(0); stalled+=(0); missed+=(0) ;;
    *)   echo "watch-findings: expected LABEL=FILE, got '$a'" >&2; exit 2 ;;
  esac
done
n=${#files[@]}

stamp="${TMPDIR:-/tmp}/review-watch-$(printf '%s\n' "$@" | cksum | cut -d' ' -f1).start"
[ -f "$stamp" ] || date +%s > "$stamp"
t0=$(cat "$stamp")

while true; do
  now=$(date +%s)
  i=0
  while [ $i -lt $n ]; do
    f=${files[$i]}; l=${labels[$i]}
    if [ -f "$f" ]; then
      out=$("$HERE/findings.sh" status "$f"); state=${out%% *}
      pend=${out#*pending=}; pend=${pend%% *}
      bytes=${out#*bytes=}; bytes=${bytes%% *}
      age=${out##*age=}
      if [ "$state" = "COMPLETE" ]; then
        if [ "${isdone[$i]}" = 0 ]; then isdone[$i]=1; echo "DONE $l: REVIEW COMPLETE, 0 PENDING, $bytes bytes"; fi
      elif [ "$age" -gt "$STALL" ] && [ "${stalled[$i]}" = 0 ]; then
        stalled[$i]=1; echo "STALLED? $l: no write for $((age / 60)) min, $pend PENDING, $bytes bytes"
      fi
    elif [ $((now - t0)) -gt "$MISSING" ] && [ "${missed[$i]}" = 0 ]; then
      missed[$i]=1; echo "MISSING? $l: no findings file $((MISSING / 60)) min after the watch started ($f)"
    fi
    i=$((i + 1))
  done
  all=1; i=0
  while [ $i -lt $n ]; do [ "${isdone[$i]}" = 1 ] || all=0; i=$((i + 1)); done
  if [ $all = 1 ]; then echo "ALL DONE — read every findings file from disk"; rm -f "$stamp"; exit 0; fi
  sleep "$INTERVAL"
done
