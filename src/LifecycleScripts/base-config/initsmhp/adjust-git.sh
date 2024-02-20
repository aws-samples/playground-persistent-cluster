#!/bin/bash

set -exuo pipefail

echo 'Set editor to /usr/bin/vim (for DL AMI)'
git config --system core.editor /usr/bin/vim

echo 'Set default branch to main'
git config --system init.defaultBranch main

echo Adjusting log aliases...
git config --system alias.lol "log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(bold white)— %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit --date=relative"
git config --system alias.lolc "! clear; git lol -\$(expr \`tput lines\` '*' 2 / 3)"
git config --system alias.lola "lol --all"
git config --system alias.lolac "lolc --all"

echo Cache git credential for 4h
git config --system credential.helper 'cache --timeout=14400'

echo Opinionated git configurations
git config --system core.editor "vim"
git config --system pull.ff "only"
git config --system merge.renormalize "true"

if command -v delta &> /dev/null ; then
    echo "adjust-git.sh: delta is available..."
    git config --system core.pager "delta -s"
    git config --system interactive.diffFilter "delta -s --color-only"
    git config --system delta.navigate "true"
fi
