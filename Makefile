# Skills install standalone, so the scripts they share are copied into each skill's scripts/.
# shared/scripts/ is the only place to edit them; `make sync` copies, `make check` verifies.

REVIEWERS := skills/contextual-review skills/cold-review
LOOP      := skills/review-loop

.PHONY: sync check

sync:
	@for d in $(REVIEWERS) $(LOOP); do \
	  install -m 755 shared/scripts/findings.sh shared/scripts/grep-terms.pl $$d/scripts/; \
	done
	@echo synced

check:
	@rc=0; for d in $(REVIEWERS) $(LOOP); do \
	  for f in findings.sh grep-terms.pl; do \
	    cmp -s shared/scripts/$$f $$d/scripts/$$f || { echo "DRIFT: $$d/scripts/$$f differs from shared/scripts/$$f"; rc=1; }; \
	  done; \
	done; \
	[ $$rc = 0 ] && echo "copies identical"; exit $$rc
