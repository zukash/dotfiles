#!/usr/bin/env bash
set -e

# Herdrからagentの状態変化イベントを受け取る
event="$HERDR_PLUGIN_EVENT_JSON"
status="$(jq -r '.data.agent_status' <<<"$event")"

# 通知対象をblocked/doneに限定する
case "$status" in
  blocked|done) ;;
  *) exit 0;;
esac

# イベントからworkspace IDとpane IDを取得する
pane_id="$(jq -r '.data.pane_id' <<<"$event")"
workspace_id="$(jq -r '.data.workspace_id' <<<"$event")"

# Herdrからworkspace名とAIセッション名を取得する
workspace="$("$HERDR_BIN_PATH" workspace get "$workspace_id" |
  jq -r '.result.workspace.label')"
message="$("$HERDR_BIN_PATH" pane get "$pane_id" |
  jq -r '.result.pane.terminal_title_stripped // .result.pane.terminal_title')"

# 通知クリック時に対象paneへ移動するコマンドを組み立てる
printf -v click '%q agent focus %q' "$HERDR_BIN_PATH" "$pane_id"

# macOSの通知を表示する
terminal-notifier \
  -title "$workspace" \
  -message "$message" \
  -activate com.mitchellh.ghostty \
  -execute "$click"
