#!/usr/bin/env bash

# EDITOR
# -------------
declare -x EDITOR="windusrf"


# Alias
alias py='python'

# update installed packages
# ----------------------------
update() {
    sudo apt update && sudo apt upgrade -y
}

# python env
# -----------------------
start-python-env() {
    . "${HOME}/${1}"/bin/activate
}
alias spe="start-python-env"
alias dpe="deactivate"

create-python-env() {
    python -m venv "${HOME}/${1}"
}
alias cpe="create-python-env"


