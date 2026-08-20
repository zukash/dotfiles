#!/bin/sh

herdr workspace get "$HERDR_ACTIVE_WORKSPACE_ID" |
  jq -r '.result.workspace.label // empty'
