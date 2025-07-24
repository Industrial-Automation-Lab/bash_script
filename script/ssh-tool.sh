#! /usr/bin/env bash

# SSH functions 
start-ssh() {
    echo "Use [start_ssh <key-name>]"
    echo "This function is only useful if your 'ssh-keys' are in your 'HOME/.ssh' directory."
    eval "$(ssh-agent -s)"
    ssh-add "${HOME}/.ssh/${1}"
}
alias ss="start-ssh"

create-ssh() {
    echo "Use [create_ssh <email>]"
    cd "${HOME}" && mkdir -p .ssh
    ssh-keygen -t ed25519 -C "${1}"
}
alias cs="create-ssh"