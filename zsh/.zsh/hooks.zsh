# ============================================================================
# Shell hooks
# ============================================================================

# herdr タブ名の自動変更 (実行中コマンド名 / idle時は zsh)
herdr_tab_rename() {
  [[ -n "$HERDR_TAB_ID" ]] || return 0
  command -v herdr >/dev/null 2>&1 || return 0
  herdr tab rename "$HERDR_TAB_ID" "$1" >/dev/null 2>&1
}

# precmd: executed before each prompt
precmd() {
  printf '\033[5 q'  # Set cursor to blinking bar
  herdr_tab_rename zsh
}

# preexec: 実行開始するコマンドの先頭語をタブ名にする
preexec() {
  herdr_tab_rename "${${=1}%% *}"
}
