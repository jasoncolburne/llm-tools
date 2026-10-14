#!/usr/bin/env bash
# new-round.sh — scaffold one review round's directory from the templates.
#
#   new-round.sh REVIEW_DIR [ROUND]
#
# REVIEW_DIR is the directory that holds every round (give it relative to the repo root, since the
# reviewers' sessions run there). ROUND defaults to the next number after the highest rNNN in it.
#
# Creates REVIEW_DIR/rNNN/ with brief-contextual.md, brief-cold.md and fold-log.md; creates
# REVIEW_DIR/designer-resume.md if absent, and REVIEW_DIR/.gitignore keeping every *-resume.md
# (session state, not part of the record) out of commits. Never overwrites. Prints what to hand
# the user: the two lines to paste into the reviewer sessions, and the watch command.

set -eu
[ $# -ge 1 ] || { sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd)
T="$HERE/../templates"
R=${1%/}

if [ $# -ge 2 ]; then
  round=$2
else
  last=$(ls "$R" 2>/dev/null | sed -n 's/^r\([0-9][0-9]*\)$/\1/p' | sort -n | tail -n 1)
  round=$(printf 'r%03d' $(( 10#${last:-0} + 1 )))
fi
D="$R/$round"
if [ -e "$D" ]; then echo "new-round: $D already exists — not overwriting" >&2; exit 1; fi
mkdir -p "$D"

fill() {  # fill TEMPLATE DEST
  sed -e "s#{{ROUND}}#$round#g" \
      -e "s#{{ROUND_DIR}}#$D#g" \
      -e "s#{{FINDINGS_CONTEXTUAL}}#$D/findings-contextual.md#g" \
      -e "s#{{FINDINGS_COLD}}#$D/findings-cold.md#g" "$1" > "$2"
}
fill "$T/brief-contextual.md" "$D/brief-contextual.md"
fill "$T/brief-cold.md"       "$D/brief-cold.md"
fill "$T/fold-log.md"         "$D/fold-log.md"
[ -e "$R/designer-resume.md" ] || fill "$T/designer-resume.md" "$R/designer-resume.md"
[ -e "$R/.gitignore" ] || printf '*-resume.md\n' > "$R/.gitignore"

cat <<EOF
Round $round scaffolded in $D
  fill every TODO(brief) in the two briefs, then:  check-brief.sh $D/brief-*.md

When the briefs are committed and the user launches the reviewers, they paste:
  contextual session:  /contextual-review $D/brief-contextual.md
  cold session:        /cold-review $D/brief-cold.md

Watch (Monitor tool, once the user says the reviewers are running):
  $HERE/watch-findings.sh contextual=$D/findings-contextual.md cold=$D/findings-cold.md
EOF
