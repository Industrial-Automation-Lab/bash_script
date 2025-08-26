#!/bin/bash

# HOME 
# --------------
declare -x HOME2="/data/data/com.termux/files/home"
declare -x WORKSPACE="${HOME2}/workspace"
# declare -x MY_CONFIG="${HOME2}/<external config file>"


# workspace setup
# -------------------
setup-workspace() {
    if [[ "$(id -u)" -eq "<user id>" ]]; then
        if [[ "${HOME}" == "<user home path>" ]]; then
            declare workspace="${HOME}/workspace"
            if [[ -d "${workspace}" ]]; then
                cd "${workspace}"
            else
                ln -s "${WORKSPACE}" "${workspace}"
                cd "${workspace}"
            fi
        else
            declare -x HOME="<user home path>"
            declare workspace="${HOME}/workspace"
            if [[ -d "${workspace}" ]]; then
                cd "${workspace}"
            else
                ln -s "${WORKSPACE}" "${workspace}"
                cd "${workspace}"
            fi
        fi
    elif [[ "$(id -u)" -eq 0 ]]; then
        if [[ "${HOME}" == "<root user home path>" ]]; then
            declare workspace="${HOME}/workspace"
            if [[ -d "${workspace}" ]]; then
                cd "${workspace}"
            else
                ln -s "${WORKSPACE}" "${workspace}"
                cd "${workspace}"
            fi
        else
            declare -x HOME="<root user home path>"
            declare workspace="${HOME}/workspace"
            if [[ -d "${workspace}" ]]; then
                cd "${workspace}"
            else
                ln -s "${WORKSPACE}" "${workspace}"
                cd "${workspace}"
            fi
        fi
    
    fi
}

# execute workspace setup
alias ws="setup-workspace"
# setup-workspace


# shell config file
# -------------------
config() {
    vi "${HOME2}/<external config file>"
}


# home shortcort
# ---------------
home2() {
	cd "${HOME2}"
}
alias hm2="home2"


# EDITOR
# -------------
declare -x EDITOR="vim"


# Alias
alias py='python'


# Environment Varaibles
# ---------------------------
declare -x LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"


# update installed packages
# ----------------------------
update() {
    pkg update && pkg upgrade -y
}


# *.md to *.pdf converter
# ----------------------------
md2pdf() {
    # use in format:
    # md2pdf <from_file.md> <to_file.pdf>
    sed -e 's/├/|/g; s/─/-/g; s/│/|/g; s/└/`/g' "${1}" > "${1%.md}_temp.md" && \
        pandoc "${1%.md}_temp.md" -o "${2}" --pdf-engine='tectonic' && rm "${1%.md}_temp.md"
}


# Gemini-CLI
# ------------------
co-pilot() {
    # use in format:
    # co-pilot gemini <project-name>
    # reppace `gemini` with any other CLI agent
    cd "${WORKSPACE}/${2}"
    "${1}"
}


# ssh agent
# -------------------
start-ssh() {
    eval "$(ssh-agent -s)"
    for ssh_key in "${@}"; do
        ssh-add "${HOME}/.ssh/${ssh_key}"
    done
}
alias ss="start-ssh"

create-ssh() {
    mkdir -p "${HOME}"/.ssh
    cd "${HOME}"
    ssh-keygen -t ed25519 -C "${1}"
}
alias cs="create-ssh"


alias sc="shellcheck"


# python env
# -----------------------
start-python-env() {
    . "${HOME}/${1}"/bin/activate
}
alias spe="start-python-env"
alias pee="deactivate"

create-python-env() {
    python -m venv "${HOME}/${1}"
}
alias cpe="create-python-env"


