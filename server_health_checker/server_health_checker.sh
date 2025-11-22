#!/usr/bin/env bash

# Server Health Checker is a tool for checking the health of a server or a group of servers by:
# - Passing a servers file (containing multiple servers) and a username
# - Making an SSH connection to each server
# - Getting its disk, memory, and CPU usage and providing a summary of the overall health
# - Using professional logging stored in /tmp/server_health.XXXXXX
# - Implementing advanced error handling with every case validation

# strict mode
set -euo pipefail

# create a log file and making it readonly
log_file=$(mktemp /tmp/server_health.XXXXXX)
readonly log_file

# log function fo logging concept [info and error]
log_info() {
    echo "[INFO] $1" | tee -a "$log_file"
}

log_error() {
    echo "[ERROR] $1" | tee -a "$log_file" >&2
}

# cleaning up function
cleanup() {
    echo ""
    echo "-------- LOG FILE CONTENT --------"
    cat "$log_file"
    echo "----------------------------------"
    echo "Deleting temporary log file: $log_file"
    rm -f "$log_file"
}

# execute this function if [INT] stopped by CTRL+C, [TERM] killed the script
trap cleanup EXIT INT TERM

# print usage function to show user how this script works
print_usage() {
    echo "[USAGE] $0 -f <server_file_path> -u <remote_user>"
}


# checking the server health function
checking_server() {
    local server="$1"
    local user="$2"
    
    log_info "Start checking server : $server ..."
    # create ssh connection to the server with the remote_user@server
    # -n => don't take any STDIN (like don't accept any keyboard inputs :)) )
    # -o => take some option like ConnectTimeout
    # the get the uptime info and disk, memory with details
    # get count of the failed password on the server (catch the HACKERS [in the most :(( ])
    
    ssh -t -q -o ConnectTimeout=5 "${user}@${server}" "bash -s" << 'KLD'
echo "---Uptime---"
uptime

echo "---Disk usage---"
df -h --total | awk 'END {print "Total: "$2 " , " "Usage: "$3 " , " "Available: "$4 " , " "Usage percent: "$5}'

echo "---Cpu usage---"
top -b -n1 | grep "Cpu(s)"

echo "---Memory usage---"
free -h --giga | awk 'NR==2 {print "Total: "$2 " , " "Usage: "$3}'

echo "---Filed Login Attempts---"
if [[ -f /var/log/auth.log ]]; then
    count=$(sudo grep -c "Failed password" /var/log/auth.log 2>/dev/null)
    echo "Failed SSH attempts: ${count:-0}"
else
    echo "Auth log not found"
fi

KLD
    
    log_info "Finished server : $server"
}

main() {
    local server_file=""
    local remote_user=""
    
    # loop on the flags options and do some commands based on a specific case
    # -f -> server file
    # -u -> remote user
    # -h -> help || how it work
    # \? -> invalid option
    # : -> missing option
    # * -> global error
    while getopts ":f:u:h" opt; do
        case "$opt" in
            f) server_file="$OPTARG";;
            u) remote_user="$OPTARG";;
            h) print_usage; exit 1;;
            \?) log_error "Invalid Option"; exit 1;;
            :) log_error "Missing Option"; exit 1;;
            *) log_error "Invalid Syntax"; print_usage; exit 1;;
        esac
    done
    
    # checking if server file and remote user is valid
    if [[ -z "$server_file" || -z "$remote_user" ]]; then
        log_error "Missing required arguments"
        print_usage
        exit 1
    fi
    
    # checking if the server file is exit in the sys
    if [[ ! -f "$server_file" ]]; then
        echo "Servers file not found !!"
        exit 1
    fi
    
    # create empty indexed array
    declare -a servers=()
    
    # loop on all line , skipping empty and commented lines then add others to the servers arr
    while IFS= read -r line;do
        [[ -z "$line" || "$line" == \#* ]] && continue
        servers+=("$line")
    done < "$server_file"
    
    log_info "Found ${#servers[@]} servers, Start Checking ..."
    
    for server in "${servers[@]}"; do
        checking_server "$server" "$remote_user"
    done
    
    log_info "All checks completed."
}

main "$@"