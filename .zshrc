export KITTY_SHELL_INTEGRATION="enabled no-title no-prompt-mark"

# Fastfetch on first interactive shell in capable terminals
if [[ $- == *i* ]] && [[ "${SHLVL:-1}" -eq 1 ]] && command -v fastfetch >/dev/null 2>&1; then
  [[ "${TERM:-}" =~ xterm-kitty ]] && sleep 0.1
  fastfetch -c "$HOME/.config/fastfetch/config.jsonc"
  echo
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.local/share/oh-my-zsh-custom"
ZSH_THEME=""
plugins=(git)
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && plugins+=(zsh-autosuggestions)
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && plugins+=(zsh-syntax-highlighting)
[ -r "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# Environment
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.bun/bin:$PATH"
export TERMINAL=kitty
export EDITOR=nvim
export VISUAL=nvim
export BUN_INSTALL="$HOME/.bun"

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Zoxide (smart cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# Prompt
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Claude Code ai-bridge channel
alias claude='claude --dangerously-load-development-channels server:ai-bridge-channel'

# Modern CLI
#alias claude="claude --dangerously-skip-permissions"
alias rmdir="rm -fr"
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons"
  alias ll="eza -la --icons"
  alias lt="eza --tree --icons --level=2"
fi
command -v bat >/dev/null 2>&1 && alias cat="bat --paging=never"
command -v lazygit >/dev/null 2>&1 && alias lg="lazygit"
[ -x "$HOME/.local/bin/betternorm" ] && alias norm="$HOME/.local/bin/betternorm"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Fixed server port so the agent-bridge daemon can wake the TUI.
# Only applies to the bare TUI launch; subcommands (mcp, serve, run...) break
# if --port is inserted before them, so they pass through untouched.
opencode() {
  if [ $# -eq 0 ]; then
    command opencode --port 14096
  else
    command opencode "$@"
  fi
}

export PATH="$PATH:$HOME/.spicetify"
