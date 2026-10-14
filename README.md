# llm-tools

Working methods for LLM sessions, packaged as Claude Code skills.

## The design–review loop

Three sessions, one terminal each:

- **designer** — owns the document. Writes the briefs, triages findings, asks the user the
  decisions that are theirs, shows the planned changes, folds them once approved.
- **contextual-reviewer** — primed on the records. Checks that the document changed as decided
  (fidelity) and that it is sound.
- **cold-read-reviewer** — reads the document with no history. Checks that it stands on its own.

One round:

1. The designer writes a durable brief for each reviewer.
2. The user pastes a brief's filename into each reviewer session (`/contextual-review <brief>`,
   `/cold-review <brief>`). Each reviewer creates its findings stub first.
3. The user tells the designer to arm the watch.
4. Each reviewer finishes by marking its findings file `REVIEW COMPLETE`.
5. The watch fires. The designer verifies the findings against the source and triages them. If
   both seats came back clean, the loop ends.
6. The designer asks the user one decision at a time.
7. The designer shows every planned change, with the calls it made.
8. The user approves.
9. The designer folds exactly what was shown.
10. Three commits: `rNNN findings`, `rNNN fold`, `r(N+1) briefs`.
11. Back to 1.

## Structure

Three skills, one per persona. The split is deliberate:

- **The cold reviewer must not carry the designer's or the contextual seat's instructions.** Those
  talk about records and rulings; the cold seat's whole value is not having them. A shared skill
  with a role argument would put them in its context.
- **Only the designer's loop is long and stateful.** The reviewers' skills are short and each
  ends with a verifiable file.
- **Each session loads only its own skill.**

```
skills/
  review-loop/          designer          /review-loop [review-dir]
    SKILL.md
    scripts/            new-round.sh  check-brief.sh  watch-findings.sh  findings.sh  grep-terms.pl
    templates/          brief-contextual.md  brief-cold.md  fold-log.md  designer-resume.md
  contextual-review/    contextual seat   /contextual-review <brief>
    SKILL.md
    scripts/            findings.sh  grep-terms.pl
    templates/          contextual-resume.md
  cold-review/          cold seat         /cold-review <brief>
    SKILL.md
    scripts/            findings.sh  grep-terms.pl
shared/scripts/         the one place findings.sh and grep-terms.pl are edited
Makefile                make sync (copy shared scripts into each skill) · make check (no drift)
```

Skills install standalone, so the shared scripts are copied into each skill rather than referenced
across directories. Edit `shared/scripts/`, run `make sync`, and `make check` fails on any drift.

## Scripts

- `findings.sh new|status|finish` — the findings-file contract. `new` creates the stub (every
  heading `PENDING`, Findings last, never overwrites). `status` reports `COMPLETE`, `IN_PROGRESS`
  or `MISSING`. `finish` appends the final `REVIEW COMPLETE` line only when no `PENDING` line
  remains. `PENDING` counts as a whole line only, so a heading that mentions the word never keeps a
  finished file looking unfinished.
- `watch-findings.sh LABEL=FILE...` — run under the Monitor tool. Prints `DONE`, `STALLED?`,
  `MISSING?` and `ALL DONE`. Uses `findings.sh status`, so "done" has one definition. The
  missing-file check catches a reviewer that never created its stub.
- `new-round.sh REVIEW_DIR` — scaffolds `rNNN/` with both briefs and a fold log from the templates,
  creates the designer's resume if absent, and prints the lines to paste and the watch command.
- `check-brief.sh` — refuses a brief with unfilled template holes. A launched brief is never
  edited in place, so a hole found afterwards costs a re-issue.
- `grep-terms.pl` — phrase search over Markdown that sees through bold/code markers, line wraps and
  sentence case. Plain `grep` quietly returns nothing on a wrapped phrase, and a reviewer reads that
  as an absence.

## Resumes

Two sessions outlive their context, so two keep a resume: the designer's and the contextual
reviewer's. The cold reviewer keeps none, by design.

The shape is meant to stay small:

- Orientation, never evidence. Every file is re-read from disk.
- Overwritten at each transition, not appended. History lives in the round directories and git.
- About 100–120 lines. Past that, detail moves to the round's fold log or findings file and the
  resume keeps a pointer.
- Pointers and next steps, not prose. Rules that live in `AGENTS.md` or memory are named, not copied.
- Untracked. `new-round.sh` writes a `.gitignore` for `*-resume.md` in the review directory.
- The contextual reviewer loads its records when a brief arrives, not at resume; the design moves
  between rounds, so priming at resume goes stale.

## Install

Symlink or copy each directory under `skills/` into `~/.claude/skills/` (user-level) or a
project's `.claude/skills/`. All three are user-invoked only (`disable-model-invocation: true`).
