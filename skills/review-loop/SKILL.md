---
name: review-loop
description:
  Run the designer's side of a dual-reviewer loop over a document or document set — write durable
  briefs for a contextual reviewer and a cold-read reviewer (each running in its own session), watch
  for their findings, triage them, ask the user only the decisions that are theirs, show the planned
  changes, fold them once approved, and repeat until a round comes back clean. Use for starting,
  continuing or resuming a review round. The reviewers use the contextual-review and cold-review skills.
disable-model-invocation: true
argument-hint: "[review-dir]"
---

# The designer's loop

The user runs three sessions: **designer** (this one), **contextual-reviewer** and
**cold-read-reviewer**. You write what the reviewers read, interpret what they write, and change
the document. You never launch a reviewer, and you never commit unless the user tells you to.

Two reviewers because each covers the other's blind spot. The **contextual** seat is primed on the
records and checks fidelity (did the document change as decided?). The **cold** seat reads the
document with no history and checks that it stands on its own. Findings both seats share are not
thereby right — they read the same source and can share a blind spot — so verify every finding
yourself.

## Layout

One review directory (default `review/`, or `$ARGUMENTS`), paths relative to the repo root:

```
review/
  designer-resume.md        your resume (untracked; a .gitignore here keeps *-resume.md out)
  contextual-resume.md      the contextual seat's resume (untracked)
  r001/
    brief-contextual.md  brief-cold.md
    findings-contextual.md  findings-cold.md      written by the reviewers
    fold-draft.md  fold-log.md                    written by you
```

Scripts are in this skill's `scripts/` (the base directory is shown when the skill loads; call
them by direct path): `new-round.sh`, `check-brief.sh`, `watch-findings.sh`, `findings.sh`
(the findings-file contract), `grep-terms.pl` (phrase search that sees through Markdown decoration
and line wraps; plain `grep` false-zeros on wrapped phrases, so use this for every phrase fact in prose).

## Resuming

If `<review-dir>/designer-resume.md` exists, read it first, then re-read from disk every file it
points at; it is orientation, never evidence. Establish the round and step from what is on disk
(which briefs and findings files exist, what the findings files' status says). After a compaction,
grep the session transcript for reasoning the summary lost; do not reconstruct it.

Keep the resume current at every transition below. **Overwrite** its sections; do not append a
log. It holds pointers and the next steps, not detail — the detail belongs in the round's fold log.

## The loop

**1. Briefs.** `new-round.sh <review-dir>` scaffolds the next round. Fill every `TODO(brief)` in
both briefs, then run `check-brief.sh` on them.

- Contextual brief: the change under review (a commit range named by commit subject), the records
  to read first, numbered checks that each have a verdict, where the risk is, what is already
  decided and must not be re-raised.
- Cold brief: the exact files to read and an instruction to open nothing else, the single question
  an outside reader should answer, the axes. **Put no history in it** — no earlier findings, no
  rulings, no hint of what was fixed. Its value is the absence.
- State the done-criterion in both: the findings file complete, and the project's gate command (if
  any) exiting 0.
- Once a brief has been handed to a reviewer it is never edited in place. A change is a new file
  (`brief-cold.v2.md`) and the reviewer is re-pointed.

**2. Launch.** Give the user the two lines `new-round.sh` printed to paste into the reviewer
sessions (`/contextual-review <brief>` and `/cold-review <brief>`). Suggest the cold session start
from a clear context.

**3. Arm the watch** when the user says the reviewers are running: start `watch-findings.sh
contextual=<file> cold=<file>` under the Monitor tool. It reports `DONE`, `STALLED?`, `MISSING?`
and finally `ALL DONE`. The Monitor tool caps a run: re-arm, with the same command, **only** on an
expiry notice, and record the task id in your resume. On `STALLED?` or `MISSING?` tell the user
which seat; they can see the session. Do not diagnose with commands.

**4. The reviewers finish** by marking their findings files `REVIEW COMPLETE`. Wait for both before
triaging; reading one first anchors you on it.

**5. Triage.** Read both findings files from disk. For every finding, read the cited lines in the
current document and the records it leans on — a reviewer can be wrong, can lack framing, or can
contradict a ruling the user made. Then classify:

- **Both seats clean** — no findings, or only ones you can decline with a recorded reason: the round
  came back clean. Update the resume, say so plainly, and stop. The loop ends here; do not ask
  what comes next.
- **Fold** — the fix is mechanical and no choice is involved.
- **Ask** — a choice between designs, a change to what the document promises, anything that
  contradicts or extends a ruling, or anything you cannot tell. When unsure, ask.
- **Decline** — mis-framed or contradicted by the source; record why. If it contradicts a ruling of
  the user's, that is an Ask, not a Decline.
- A finding that comes back round after round in new words means the premise is wrong, not the
  wording. Name the thing it keeps patching and raise the premise.

**6. Questions.** One decision at a time, each in four labeled parts: **the gap** (what is wrong or
unsettled, with every term defined inside it), **a concrete example** (a specific case, not the
category), **the recommendation**, **the outcome** (what the document says after). Plain words.
If the user answers with questions, answer them and leave the decision open. If they say a wording
is unclear, reword it and show it before it is ruled. Never mark a question deferred yourself; a
deferral is only what the user deferred. Record each ruling in their own words, with the time.

**7. The show.** Write `fold-draft.md` and show it: every edit as location, **before → after**
verbatim, the finding id, and the ruling or call behind it. Calls you made without asking are
lettered and declinable. For each property you change, search for every other place the document
states it (`grep-terms.pl`) and list those sites too. Edit nothing yet.

**8. The go.** Wait for the user's explicit approval. A question is not an approval.

**9. The fold.** Apply exactly the shown set. Anything you find worth changing while applying is a
**post-go change**: stop, show it, get it approved. Never launch a round with an open item. Then
read every changed passage whole and every sibling place that states the same property — the
reading is the check, scripts only support it — and run the project's gate. Write `fold-log.md`
(`templates/fold-log.md`): count, each finding's disposition, rulings quoted with times, calls,
what was not acted on, checks run.

**10. Commits.** A round commits three things, in order: `rNNN findings` (both findings files),
`rNNN fold` (document changes plus the fold log), and the next round's briefs
(`r(N+1) briefs`). So scaffold and fill the next round's briefs now, before the user commits, and
`check-brief.sh` them; they name the fold commit as their base by its subject. Give the user the
three file sets and messages. The first round has only its briefs to commit. Commit only if told to.

**11.** Back to step 1 for the next round. Any fold that changed the document means another round.
