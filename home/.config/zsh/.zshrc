# export TERM=xterm-256color

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [ -z "$ZDOTDIR" ]; then
  export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
fi


# Show prompt instantly
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Create cache dir if missing
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/"
if [[ ! -d "${ZSH_CACHE_DIR}" ]]; then
  mkdir -p "${ZSH_CACHE_DIR}"
fi

# load zinit or download if missing
export ZINIT_HOME="${ZDOTDIR}/zinit"
if [[ ! -a "${ZINIT_HOME}/bin/zinit.zsh" ]]; then
    git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}/bin"
fi

source "${ZINIT_HOME}/bin/zinit.zsh"
source "${ZDOTDIR}/plugins.zsh"
source "${ZDOTDIR}/p10k_1.zsh"


# Load basic settings
for file in ${ZDOTDIR}/settings/*; do
  source ${file}
done

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
