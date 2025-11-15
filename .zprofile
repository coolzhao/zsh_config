#!/bin/zsh
#
# .zprofile - Zsh file loaded on login.
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER="${BROWSER:-open}"
fi

#
# Editors
#

export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"
export PAGER="${PAGER:-less}"

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# Set the list of directories that zsh searches for commands.
path=(
  $HOME/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /usr/local/{,s}bin(N)
  $path
)

if [[ "$OSTYPE" == darwin* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
#
# Auto-launching ssh-agent on Git
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
