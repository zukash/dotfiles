#!/bin/sh

branch=$(git -C "$HERDR_ACTIVE_PANE_CWD" branch --show-current 2>/dev/null) || exit 0
[ -n "$branch" ] || exit 0

if [ -n "$(git -C "$HERDR_ACTIVE_PANE_CWD" status --porcelain 2>/dev/null)" ]; then
  printf '%s*' "$branch"
else
  printf '%s' "$branch"
fi
