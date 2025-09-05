#!/usr/bin/env bash

# SSH functions 
start-ssh() {
    # Use [start_ssh <key-name>]
    # This function is only useful if your 'ssh-keys' are in your 'HOME/.ssh' directory.
    for ssh_key in "${@}"; do
    	eval "$(ssh-agent -s)"
        ssh-add "${HOME}/.ssh/${ssh_key}" || "Key not in -> [${HOME}/.ssh]"
    done
}
alias ss="start-ssh"

create-ssh() {
    # Use [create_ssh <email(s)>]
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

compress() {
    # compresses audio files to <x> MB size 
    
    if [[ "${1}" == "--help" || "${1}" == "-h" ]] && [[ -z "${2}" ]]; then
        echo "Usage: compress input.m4a [--size -s] ${default_target_mb} [--max_attempts -ma] ${default_max_attempts}"
        return 0
    else
        echo "Invalid flag: [${2}]"
        echo "use: [--help -h]"
        return 2
    fi
    
    if [[ "$(which ffmpeg)" == "" ]]; then
        sudo apt update
        sudo apt install ffmpeg -y
    fi
    
    declare -a flags=("--size" "--max_attempt" "-s" "-ma")
    local in="${1}"; shift
    declare -a args=("${@}")
    local ext="${in##*.}"
    local out="${in%.*}_compressed.${ext}"
    local attempt=1
    local default_target_mb=15
    local default_max_attempts=3
    
    # Exception Handling for [Audio file Existence Checking] and [Argument Not Given]
    if [[ -z "${1}" ]]; then
      echo "Usage: [compress input.m4a --size/-s ${default_target_mb} --max_attempts/-ma ${default_max_attempts}]"
      return 1
    elif [[ ! -f "${in}" ]]; then
        echo "FileNotFoundError: [${in}]"
        return 1
    else
        # Maps given args to Varaible
        if [[ "${#args[@]}" == 4 ]]; then
            if [[ "${args[0]}" == "--size" || "${args[0]}" == "-s" ]] && [[ "${args[2]}" == "--max_attempt" || "${args[2]}" == "-ma" ]]; then
                local target_mb="${args[1]}" # size
                local max_attempts="${args[3]}" # Max Attempts
                
            elif [[ "${args[0]}" == "--max_attempt" || "${args[0]}" == "-ma" ]] && [[ "${args[2]}" == "--size" || "${args[2]}" == "-s" ]]; then
                local target_mb="${args[3]}" # size
                local max_attempts="${args[1]}" # Max Attempts 
            else
                echo "Invalid Flags: [${args[@]}]"
                echo "use flags: [${flags[@]}]"
                return 2
            fi
        elif [[ "${#args[@]}" == 2 ]]; then
            if [[ "${args[0]}" == "--size" || "${args[0]}" == "-s" ]]; then
                local target_mb="${args[1]}"
                local max_attempts="${default_max_attempts}"
            elif [[ "${args[0]}" == "--max_attempt" || "${args[0]}" == "-ma" ]]; then
                local target_mb="${default_target_mb}"
                local max_attempts="${args[1]}"
            else
                echo "Invalid Flag: [${args[0]}]"
                echo "use flags: [${flags[@]}]"
                return 2
            fi
        else
            echo "ArgError: [${@}]"
            echo "use flags: [${flags[@]}]"
            return 2
        fi
        
        # get duration in seconds (float)
        duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in")
        if [ -z "$duration" ]; then
          echo "Could not read duration from $in"
          return 2
        fi
        
        # compute initial bitrate (kbps), apply safety factor 0.97, round
        target_kbps=$(awk -v mb="$target_mb" -v d="$duration" 'BEGIN{ printf("%.0f", (mb*8000)/d*0.97) }')
        
        echo "Duration: $duration s"
        echo "Initial target bitrate: ${target_kbps} kb/s"
        
        current_kbps="$target_kbps"
        
        while [ $attempt -le $max_attempts ]; do
          echo "Attempt $attempt: encoding at ${current_kbps}k ..."
          ffmpeg -hide_banner -y -i "$in" -c:a aac -b:a "${current_kbps}k" -movflags +faststart "$out"
        
          actual_bytes=$(stat -c%s "$out" 2>/dev/null || stat -f%z "$out" 2>/dev/null)
          actual_mb=$(awk -v b="$actual_bytes" 'BEGIN{ printf("%.3f", b/1000000) }')
        
          echo "Resulting file: $out → ${actual_mb} MB"
        
          # if within target (allow tiny slack 0.98), break
          cmp=$(awk -v a="$actual_mb" -v t="$target_mb" 'BEGIN{ print (a <= t) ? 0 : 1 }')
          if [ "$cmp" -eq 0 ]; then
            echo "Success: file <= ${target_mb} MB"
            return 0
          fi
    
          # adjust bitrate proportionally and retry
          ratio=$(awk -v t="$target_mb" -v a="$actual_mb" 'BEGIN{ print t/a }')
          new_kbps=$(awk -v k="$current_kbps" -v r="$ratio" 'BEGIN{ printf("%.0f", k * r * 0.98) }')
          echo "File too large; adjusting bitrate: ${current_kbps} -> ${new_kbps} and retrying."
          current_kbps="$new_kbps"
          ((attempt++))
        done
        
        echo "Finished: encoded file is ${actual_mb} MB (may still exceed ${target_mb} MB)."
        return 0
    fi
}
