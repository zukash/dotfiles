notify() {
  local message="$*"
  curl -H "Content-Type: application/json" \
       -d "{\"content\": \"$message\"}" \
       "$DISCORD_WEBHOOK_URL"
}

fzf-z-search() {
  local res=$(z | sort -rn | cut -c 12- | fzf-tmux -p)
  if [ -n "$res" ]; then
    BUFFER+="cd $res"
    zle accept-line
else
    return 1
  fi
}
zle -N fzf-z-search
bindkey '^z' fzf-z-search

function ghq-tmux() {
  local repo_path session_name

  repo_path=$(ghq list -p | fzf-tmux -p) || return

  local rel_path=${repo_path#$(ghq root)/}   # github.com/org/repo
  local org_repo=${rel_path#*/}              # org/repo

  local org=${org_repo%%/*}
  local repo=${org_repo##*/}

  session_name="[$org] $repo"

  tmux has-session -t "$session_name" 2>/dev/null
  if [ $? != 0 ]
  then
    tmux new-session -s "$session_name" -d -c "$repo_path"
  fi
  tmux switch-client -t "$session_name"  
}
