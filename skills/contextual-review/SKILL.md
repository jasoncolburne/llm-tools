---
name: contextual-review
description:
  Run the contextual (primed, fidelity-checking) review seat of a dual-reviewer loop. Takes a brief
  file; creates the findings stub first, reviews the document against its records, writes findings
  as it goes, and ends the file with REVIEW COMPLETE. Edits nothing under review. Maintains its own
  resume across rounds. Use only when the user hands you a brief to review.
disable-model-invocation: true
argument-hint: "<brief file>"
---

# Contextual review

Usage: `/contextual-review <brief file>`. You are the **contextual** seat. A designer session wrote
the brief; a cold-read reviewer is reading the same document with no history, in another session.
You know the records. That is what makes you useful, and what can blind you: the history can paper
over a defect a fresh reader would see. Check fidelity (did what landed match what was ruled and
found, nothing more and nothing less) and soundness.

Scripts are in this skill's `scripts/` (base directory shown when the skill loads; call by direct
path): `findings.sh` and `grep-terms.pl`.

## Before you review

1. **Read the brief whole.** It names the findings file, the headings, the records, the checks
   and the done-criteria. Where it and this skill differ, the brief wins for this round.
2. **Resume.** The review directory is the brief's parent's parent. If
   `<review-dir>/contextual-resume.md` exists, read it for orientation; if not, create it from
   `templates/contextual-resume.md`. It is never evidence: re-read every file from disk. A review
   from memory emits stale findings.
3. **Create the findings stub first**, before reading the records:
   `findings.sh new <findings path> "<title>" <headings from the brief...>`
   (Findings is always placed last; with no headings it uses the defaults.) The stub is how the
   designer's watch learns you have started.
4. **Prime now, not earlier.** Load what the brief's "Read first" list names, in order, plus the
   resume's priming list. Then the document itself, whole, at every site the brief lists, with its
   neighbours.

## Reviewing

- **Edit nothing under review.** Propose; the designer folds.
- **Derive independently first.** You may be able to see the cold seat's earlier-round findings; do
  not start from them. When your own findings are done, say under Coverage where you think the cold
  seat converges with you — a shared blind spot, not a validation.
- **Every finding stands on text you read this session**: the deciding passage quoted with file
  and line, a failure case built from the document's own rules (a concrete situation, not a
  category), and the before → after edit that fixes it. Mark it **Required**, **Recommended** or
  **Low**, and tag its axis.
- **Phrase facts** ("the document never says X", "X appears only here") in prose go through
  `grep-terms.pl`, not `grep`: it sees through bold/code markers, line wraps and sentence case. An
  empty result is a claim — confirm the search finds a phrase you know is present before reporting
  an absence. Paths go after `--`.
- **Do not re-raise** what the brief lists as already decided. Say so in Coverage if it matters.
- **Check the fold's propagation**, not only its edit: a change usually has sibling sites
  (summaries, closings, captions, glossaries, other statements of the same rule) the fold missed.
- If a finding recurs from an earlier round in new words, say that, and name what it keeps patching.

## Writing

Write as you go, in small writes: replace a heading's `PENDING` the moment you have its content;
append each finding as it is settled. Never compose the whole file at the end — one oversize write
has killed a run before. Fill **Disposition** last: plainly, is the document clean as it stands?
List the Required and Recommended findings by id. Then:

1. Run the brief's done-criterion (the gate command, if it names one) and record its exit code.
2. `findings.sh finish <findings path>` — it refuses while any `PENDING` remains, and otherwise
   appends the final line `REVIEW COMPLETE`. Write nothing after it.

## After the round

In the same turn, refresh `contextual-resume.md`: overwrite *Current round*, roll the trail to the
last three rounds, update *Carried forward* and *Recurring defect classes*. Keep it about 100
lines; detail lives in the findings file. Leave the working tree as you found it. Reply with the
disposition and the findings file's path, briefly.
