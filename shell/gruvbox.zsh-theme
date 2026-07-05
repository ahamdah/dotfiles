# =============================================================================
# gruvbox.zsh-theme — Gruvbox Dark prompt for Oh My Zsh
# =============================================================================

PROMPT='%F{#83a598}%~%f $(git_prompt_info)%(?.%F{#b8bb26}.%F{#fb4934})❯%f '

ZSH_THEME_GIT_PROMPT_PREFIX="%F{#928374}git:(%F{#fabd2f}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%F{#928374})%f "
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{#fe8019}✗%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""
