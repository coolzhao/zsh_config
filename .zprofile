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

# Check if agent is running (0 = running w/ keys, 1 = running w/o keys, 2 = not running)
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
fi

# Function to check if a specific key is already loaded in the agent, and load it if missing
add_key_if_missing() {
    local key_path="$1"
    
    # Only proceed if the private key file actually exists on this system
    if [ -f "$key_path" ]; then
        local fingerprint
        
        # Get the SHA256 fingerprint of the key file (e.g. "SHA256:abc...").
        # ssh-keygen -lf extracts the fingerprint. awk '{print $2}' retrieves just the hash column.
        fingerprint=$(ssh-keygen -lf "$key_path" 2>/dev/null | awk '{print $2}')
        
        # Check if the fingerprint is non-empty and NOT found in the list of currently loaded keys.
        # ssh-add -l lists loaded keys. grep -q searches silently for the fingerprint.
        if [ -n "$fingerprint" ] && ! ssh-add -l 2>/dev/null | grep -q "$fingerprint"; then
            # Key is not loaded, so add it to the active SSH agent session
            ssh-add "$key_path"
        fi
    fi
}

# Ensure both local keys are checked and loaded if missing from the active agent
add_key_if_missing ~/.ssh/id_rsa
add_key_if_missing ~/.ssh/id_ed25519

unset env
