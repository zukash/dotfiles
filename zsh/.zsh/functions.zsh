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

# GHQ integration with tmux for project management
ghq-tmux() {
  if [ -n "$1" ]; then
    repo_path="$1"
  else
    repo_path=$(ghq list -p | fzf-tmux -p 80%) || return
  fi
  session_name=${repo_path#$(ghq root)/*/}   # org/repo

  # Check if the session already exists
  tmux has-session -t "$session_name" 2>/dev/null
  if [ $? != 0 ]
  then
    tmux new-session -s "$session_name" -d -c "$repo_path"
  fi

  # Attach to the session or switch to it
  if [ -z "$TMUX" ]; then
    tmux attach-session -t "$session_name"
  else
    tmux switch-client -t "$session_name"  
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
