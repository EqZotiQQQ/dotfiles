alias vim="nvim"

if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
else
  alias ls='ls --color' 
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi

if command -v duf >/dev/null 2>&1; then
  alias df='duf'
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
  # https://github.com/BurntSushi/ripgrep
fi
