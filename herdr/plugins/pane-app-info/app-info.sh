#!/usr/bin/env bash
set -euo pipefail

# Herdr CLIの実行パスを決める
herdr="$HERDR_BIN_PATH"

# Herdrからpaneイベントを受け取る
event="$HERDR_PLUGIN_EVENT_JSON"
pane_id="$(jq -r '.data.pane_id // .data.pane.pane_id // empty' <<<"$event")"
[ -n "$pane_id" ] || exit 0

# paneイベント直後のshell初期化を待つ
sleep 0.1

# Herdrからforeground processの情報を取得する
info="$($herdr pane process-info --pane "$pane_id")" || exit 0
app="$(jq -r '.result.process_info.foreground_processes[0].argv0 // .result.process_info.foreground_processes[0].name // empty' <<<"$info")"
[ -n "$app" ] || exit 0

# paneが所属するtab IDを取得する
tab_id="$($herdr pane get "$pane_id" | jq -r '.result.pane.tab_id // empty')" || exit 0
[ -n "$tab_id" ] || exit 0

# focused paneのアプリ名でtab名を更新する
"$herdr" tab rename "$tab_id" "$app" >/dev/null
