SHELL := /bin/bash

NVIM_SRC ?= $(HOME)/.config/nvim
NVIM_DEST ?= .config/nvim

.PHONY: sync-nvim
sync-nvim:
	@set -euo pipefail; \
	if [ ! -d "$(NVIM_SRC)" ]; then \
		echo "Source not found: $(NVIM_SRC)"; \
		exit 1; \
	fi; \
	mkdir -p "$(NVIM_DEST)"; \
	rsync -a --delete --exclude '.nvimlog' "$(NVIM_SRC)/" "$(NVIM_DEST)/"; \
	git add -A "$(NVIM_DEST)"; \
	if git diff --cached --quiet -- "$(NVIM_DEST)"; then \
		echo "No changes detected in $(NVIM_DEST). Nothing to commit."; \
		exit 0; \
	fi; \
	if [ -n "$(COMMIT_MSG)" ]; then \
		msg='$(COMMIT_MSG)'; \
	else \
		msg="chore(nvim): sync config ($$(date '+%Y-%m-%d %H:%M:%S'))"; \
	fi; \
	git commit -m "$$msg"; \
	branch="$$(git branch --show-current)"; \
	git push origin "$$branch"; \
	echo "Synced, committed, and pushed to $$branch.";
