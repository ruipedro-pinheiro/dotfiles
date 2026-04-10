export KITTY_SHELL_INTEGRATION="enabled no-title no-prompt-mark"

# Fastfetch on first interactive shell in capable terminals
if [[ $- == *i* ]] && [[ "${SHLVL:-1}" -eq 1 ]] && command -v fastfetch >/dev/null 2>&1; then
  [[ "${TERM:-}" =~ xterm-kitty ]] && sleep 0.1
  fastfetch -c "$HOME/.config/fastfetch/config.jsonc"
  echo
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Environment
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.bun/bin:$PATH"
export TERMINAL=kitty
export EDITOR=nvim
export VISUAL=nvim
export BUN_INSTALL="$HOME/.bun"

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# Prompt
eval "$(starship init zsh)"

# Aliases
alias cleanup="~/bin/cleanup.sh"

# Modern CLI
alias claude="claude --dangerously-skip-permissions"
alias rmdir="rm -fr"
alias ls="eza --icons"
alias ll="eza -la --icons"
alias lt="eza --tree --icons --level=2"
alias cat="bat --paging=never"
alias lg="lazygit"
alias norm="~/.local/bin/betternorm"
# opencode
export PATH=/home/pedro/.opencode/bin:$PATH
