#!/bin/zsh
#
# .zshenv - Zsh environment file, loaded always.
#

# NOTE: .zshenv needs to live at ~/.zshenv, not in $ZDOTDIR!

# Set ZDOTDIR if you want to re-home Zsh.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
# Override ZDOTDIR if it is unset, or if it points to HOME (e.g., set by IDE terminal integration).
# This ensures Zsh configurations are correctly loaded from ~/.config/zsh rather than defaulting to HOME.
if [[ -z "$ZDOTDIR" || "$ZDOTDIR" == "$HOME" ]]; then
  export ZDOTDIR=$XDG_CONFIG_HOME/zsh
fi

# You can use .zprofile to set environment vars for non-login, non-interactive shells.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# Source cargo environment variables for Rust
. "$HOME/.cargo/env"
