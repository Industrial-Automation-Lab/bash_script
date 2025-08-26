#!/usr/bin/env bash

# SSH functions 
start-ssh() {
    echo "Use [start_ssh <key-name>]"
    echo "This function is only useful if your 'ssh-keys' are in your 'HOME/.ssh' directory."
    for ssh_key in "${@}"; do
    	eval "$(ssh-agent -s)"
        ssh-add "${HOME}/.ssh/${ssh_key}" || "Key not in -> [${HOME}/.ssh]"
    done
}
alias ss="start-ssh"

create-ssh() {
    echo "Use [create_ssh <email>]"
    if [[ -d "${HOME}/.ssh" ]]; then
        for email in "${@}"; do
            ssh-keygen -t ed25519 -C "${email}"
        done
    else
        cd "${HOME}" && mkdir -p .ssh
        for email in "${@}"; do
            ssh-keygen -t ed25519 -C "${email}"
        done
    fi
}
alias cs="create-ssh"
