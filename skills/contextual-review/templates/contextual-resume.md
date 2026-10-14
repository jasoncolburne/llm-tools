# Contextual reviewer resume — read after a `/clear` or `/compact`

<!--
How this file works (delete this comment once the file is in use)
- It is ORIENTATION, never evidence. Re-read every file from disk each round; a review from memory
  emits stale findings.
- Priming happens WHEN A BRIEF IS IN HAND, not at resume: the design moves between rounds, so
  loading records at resume wastes tokens on context that goes stale. This file says what to load;
  it does not hold it.
- Refresh it at the end of every round, in the same turn as the verdict. OVERWRITE "Current round"
  and roll the trail; never accumulate per-round detail here — each round's detail is its findings
  file, and this file only indexes. Budget: about 100 lines.
- Never hand this file to a cold reviewer. The cold seat gets no history, by design.
-->

## Role (stable)

Contextual reviewer. The human coordinates by hand and does the git. A brief arrives as a file path;
my findings go to the path the brief names. I edit nothing under review. The cold seat reads the
document with no history; I read it against its records and derive my findings independently before
comparing to anything the cold seat wrote.

## Priming — load when a brief arrives

- The brief's "Read first" list, in order.
- TODO (cross-cutting records every round needs: the glossary, the invariants, the reconciliation
  or decision register, the design's reading order)
- Not mine to maintain: the designer's resume. Read a named block of it only if a brief points there.
- Historical or archived material misleads; never cite it as current.

## Current round — overwrite each round

- Round: TODO · brief: TODO · findings: TODO
- State: TODO (stub created / in progress / complete) · done-gate: TODO (command, exit code)
- Disposition: TODO (clean / N Required, M Recommended), one sentence
- Findings: TODO (id — severity — five words, up to about ten)
- Where I think the cold seat converges with me (a shared-blind-spot flag): TODO

## Carried forward

- Flagged for a later pass, not for the designer's fold: TODO (item — source)
- Known debts the briefs say not to raise (so I do not): TODO (item — source)

## Recurring defect classes — carry into the next brief's checks

- TODO (a class found in more than one round, stated as a check: "a fold's site list must include X")

## Trail — the last three rounds, one line each

- TODO `rNNN` — date — disposition — `review/rNNN/findings-contextual.md`
