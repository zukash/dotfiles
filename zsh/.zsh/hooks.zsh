# ============================================================================
# Shell hooks
# ============================================================================

# precmd: executed before each prompt
precmd() {
  printf '\033[5 q'  # Set cursor to blinking bar
}
