# Cold review brief — {{ROUND}}: TODO(brief) one-line scope

You are the **cold** seat. Your value is that you have read nothing about how this document got here.

## What to read, and what not to

**Read exactly these files, whole, front to back:**

TODO(brief) The subject document(s), by path, one per line. Treat them as the document. Do not read
them as a diff; there is nothing to diff against.

**Open nothing else.** Not the records, not the review directory, not the git history, and — this
matters most — not any earlier findings file. Other cold seats have read versions of this document
before you; if you reach a conclusion because one of them wrote it down, you have added nothing.
If your context already carries a memory, a summary of rulings, or any account of this document's
history, say so under **Coverage** and open none of it. Every finding rests on a quoted line of the
files above.

## What you are answering

TODO(brief) The one question, in terms of an outside reader — e.g. "would a competent implementer
build the same system from this document?", "does this hold together as written?". Then the axes,
as numbered checks; mark the must-answer ones with ★. Each finding names a rule the document
states, a case built from the document's own rules in which that rule fails or two rules disagree,
and the sentence you would put in its place. Before proposing a sentence that adds a rule, ask
whether a sentence already there is what is wrong — a clause that handles one case its own way —
and say so where deleting it would let the general rules decide.

## Done criteria

- The findings file ends with `REVIEW COMPLETE` and holds no `PENDING` line.
- TODO(brief) The project's gate command exits 0 (name it) — or delete this line if there is none.
- Nothing was edited; the working tree is as you found it.

## Findings file

Path: `{{FINDINGS_COLD}}`

Create it **first**, before reading anything else, with these headings in this order, each holding
the single line `PENDING` and nothing else: **Disposition**, **Verdict per check**, **Coverage,
method, and where I am unsure**, **Findings** (last).

- Replace a heading's `PENDING` the moment you have its content. Append each finding as it is
  settled, in small writes; never compose the file in one write at the end.
- Each finding: an id (`F1`…), a severity (**Required** / **Recommended** / **Low**), an axis tag,
  the deciding text quoted with its file and line, a failure case, and the before → after edit.
- Reviewers propose edits; they do not make them.
- Disposition is filled last: say plainly whether the document is clean as it stands, and list
  the Required and Recommended findings by id.
- When no `PENDING` remains, the last line of the file is exactly `REVIEW COMPLETE`, and nothing
  follows it.
