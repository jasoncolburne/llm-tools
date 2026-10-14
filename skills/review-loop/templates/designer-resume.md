# Designer resume — read after a `/clear` or `/compact`

<!--
How this file works (delete this comment once the file is in use)
- It is ORIENTATION, never evidence. Re-read every file named here from disk before acting on it.
- OVERWRITE the sections below at each transition; do not append a log. History lives in the round
  directories (briefs, findings, fold logs) and in git. Budget: about 120 lines. Past that, move
  the detail into the round's fold log and leave a pointer.
- Hold pointers (paths, ids, commit subjects), not prose. Rules that live elsewhere (AGENTS.md,
  memory) are named, not copied.
- After a compaction, grep the session transcript for reasoning the summary lost rather than
  reconstructing it.
-->

## Role (stable)

I am the designer for TODO (project / document set). The human runs the reviewers in separate
sessions; I write briefs, triage findings, ask for the decisions only they can make, show the
changes, and fold them once approved. I never launch a reviewer and never commit unless told to.
Process: the `review-loop` skill. Standing preferences: TODO (pointer to AGENTS.md / memory).

## Where things live (stable)

- Subject documents: TODO
- Review directory: TODO (rounds in `rNNN/`)
- Project gate: TODO (the command that must exit 0 after a fold)
- Records the briefs point the contextual reviewer at: TODO

## Loop state — overwrite at every transition

- Round: TODO
- Step (1 briefs · 2 launch · 3 watch armed · 4 reviewers running · 5 triage · 6 questions · 7 show ·
  8 go · 9 fold · 10 commits): TODO
- Present on disk: briefs TODO · findings contextual TODO / cold TODO · fold log TODO · fold draft TODO
- Watch: TODO (the exact command; Monitor task id; armed at; re-armed at)
- Last commit triple: TODO (`rNNN findings`, `rNNN fold`, `r(N+1) briefs`), or none yet

## Next (the literal next steps, with this round's names)

1. TODO
2. TODO

## Decisions this round

One line each; the quoted ruling and its time live in the fold log, not here.

| Id  | The question in a few words | State (open / ruled / declined / deferred) |
| --- | --------------------------- | ------------------------------------------ |
|     |                             |                                            |

## Deferred — only what the user explicitly deferred

- TODO (what, until when, who raised it)

## Defect classes that keep recurring — check these before every show

- TODO (a class of mistake found in more than one round, as a check to run)

## Trail — the last three rounds, one line each

- TODO `rNNN` — date — outcome (clean / N Required, M Recommended) — `review/rNNN/fold-log.md`
