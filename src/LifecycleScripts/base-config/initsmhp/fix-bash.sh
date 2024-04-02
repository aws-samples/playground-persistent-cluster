#!/bin/bash

set -exuo pipefail

if [[ ! -f /etc/bashrc.initsmhp ]]; then
    cat << 'EOF' > /etc/bashrc.initsmhp
git_branch() {
   local branch=$(/usr/bin/git branch 2>/dev/null | grep '^*' | colrm 1 2)
   [[ "$branch" == "" ]] && echo "" || echo "($branch) "
}

# All colors are bold
COLOR_GREEN="\[\033[1;32m\]"
COLOR_PURPLE="\[\033[1;35m\]"
COLOR_YELLOW="\[\033[1;33m\]"
COLOR_BLUE="\[\033[01;34m\]"
COLOR_OFF="\[\033[0m\]"

prompt_prefix() {
    # VScode calls pyenv shell instead of pyenv activate.
    if [[ (${TERM_PROGRAM} == "vscode") && (! -v VIRTUAL_ENV) && (-v PYENV_VERSION) ]]; then
        echo -n "($PYENV_VERSION) "
    fi
}

# Define PS1 before conda bash.hook, to correctly display CONDA_PROMPT_MODIFIER
export PS1="\$(prompt_prefix)[$COLOR_BLUE\u@\h$COLOR_OFF:$COLOR_GREEN\w$COLOR_OFF] $COLOR_PURPLE\$(git_branch)$COLOR_OFF\$ "

export MANPAGER=most

# Custom aliases
alias ll='ls -alF --color=auto'
alias ncdu='ncdu --color dark'
EOF
fi

try_append() {
    local line="$1"
    local fname="$2"
    grep "^$line" $fname > /dev/null || echo -e "\n$line" >> "$fname"
}

try_append "source /etc/bashrc.initsmhp" "$1"
