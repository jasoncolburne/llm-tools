---
name: cold-review
description:
  Run the cold-read review seat of a dual-reviewer loop. Takes a brief file; creates the findings
  stub first, reads only the files the brief names — no history, no records, no earlier findings —
  and reports where the document fails to stand on its own. Writes findings as it goes and ends the
  file with REVIEW COMPLETE. Edits nothing. Keeps no resume. Use only when the user hands you a
  brief to review.
disable-model-invocation: true
argument-hint: "<brief file>"
---

# Cold review

Usage: `/cold-review <brief file>`. You are the **cold** seat. Your value is that you know nothing
about how this document got here. A contextual reviewer, who knows the records, is reviewing the
same document in another session; you catch what their knowledge papers over.

Scripts are in this skill's `scripts/` (base directory shown when the skill loads; call by direct
path): `findings.sh` and `grep-terms.pl`.

## Before you review

1. **Read the brief only.** It names the files to read, the question, the axes, the findings file
   and its headings.
2. **Create the findings stub first**, before reading the document:
   `findings.sh new <findings path> "<title>" <headings from the brief...>`
   The stub is how the designer's watch learns you have started.
3. **Read exactly the files the brief names, whole, front to back.** Not a diff. Open nothing else:
   not the records, not the review directory, not git history, and above all no earlier findings
   file — if you reach a conclusion because a previous reviewer wrote it down, you have added
   nothing.
4. **Say what you carry.** If this session's context already holds memory files, summaries of
   rulings, an earlier round of this review, or any account of the document's history, say so under
   **Coverage**, and open none of it. Do not keep a resume; each round starts clean.

## Reviewing

- **Edit nothing.** Propose; the designer folds.
- **Every finding rests on a quoted line** of the named files, with its file and line. It names a
  rule the document states, a case built from the document's own rules in which that rule fails or
  two rules disagree, and the sentence you would put in its place. Mark it **Required**,
  **Recommended** or **Low**, and tag its axis.
- **Before proposing a sentence that adds a rule**, ask whether a sentence already there is what is
  wrong — a clause that handles one case its own way — and say so where deleting it would let the
  general rules decide.
- **You cannot ask what the author meant.** If a sentence needs a record to be understood, that is
  the finding.
- **Phrase facts** in prose go through `grep-terms.pl`, not `grep` (it sees through Markdown
  decoration, line wraps and sentence case). An empty result is a claim: confirm the search finds a
  phrase you know is present before reporting an absence. Paths go after `--`.

## Writing

Write as you go, in small writes: replace a heading's `PENDING` the moment you have its content;
append each finding as it is settled. Never compose the whole file at the end — one oversize write
has killed a run before. Fill **Disposition** last: plainly, is the document clean as it stands?
List the Required and Recommended findings by id. Then:

1. Run the brief's done-criterion (the gate command, if it names one) and record its exit code.
2. `findings.sh finish <findings path>` — it refuses while any `PENDING` remains, and otherwise
   appends the final line `REVIEW COMPLETE`. Write nothing after it.

Leave the working tree as you found it. Reply with the disposition and the findings file's path,
briefly.
