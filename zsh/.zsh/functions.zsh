# Send notification to Discord
notify() {
  local message="$*"
  curl -H "Content-Type: application/json" \
       -d "{\"content\": \"$message\"}" \
       "$DISCORD_WEBHOOK_URL"
}

# FZF integration with z for directory jumping
fzf-z-search() {
  local res=$(z | sort -rn | cut -c 12- | fzf-tmux -p)
  if [ -n "$res" ]; then
    BUFFER+="cd $res"
    zle accept-line
  else
    return 1
  fi
}

pane-view() {
  local f=$(mktemp) s=$(mktemp)
  tmux capture-pane -e -J -pS - | perl -0777 -pe 's/\s+$/\n/' > "$f"
  printf '%s\n' \
    'function! OpenPane(p) abort' \
    '  enew' \
    '  let c = nvim_open_term(0, {})' \
    '  call chansend(c, join(readfile(a:p), "\n"))' \
    '  normal! G' \
    'endfunction' \
    "call OpenPane('$f')" \
    "autocmd VimLeave * call delete('$f') | call delete('$s')" \
    > "$s"
  tmux new-window -a -- nvim -S "$s"
}
