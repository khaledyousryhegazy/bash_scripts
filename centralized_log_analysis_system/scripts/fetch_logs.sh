#!/usr/bin/env bash

set -euo pipefail

log_file="./log_process/process.log"

echo "==========Starting Fetch Log==========" >> "$log_file"

remote_user=""
server_name=""
log_path=""

mkdir -p log_process
mkdir -p logs

log_info() {
    echo "[*][INFO] $1" | tee -a "$log_file"
}

log_error() {
    echo "[*][ERROR] $1" | tee -a "$log_file"
}

print_usage() {
    echo "[USAGE] $0 -u <remote_user> -s <server_name> -p <logs_path>"
}

while getopts "u:s:p:h" opt;do
    case "${opt}" in
        u) remote_user="${OPTARG}";;
        s) server_name="${OPTARG}";;
        p) log_path="${OPTARG}";;
        h) print_usage; exit 0;;
        \?) echo "Invalid Option"; print_usage; exit 1;;
        *) echo "Something goes wrong"; exit;;
    esac
done

if [[ -z "$remote_user" || -z "$server_name" || -z "$log_path" ]];then
    log_error "Missing Arguments"
    print_usage
    exit 1
fi

log_info "[$(date +%Y-%m-%d)] Starting Centralized Log Analysis System ..."
log_info "Fetching logs from $server_name"

if rsync -avz "$remote_user@$server_name:$log_path" ./logs/ | tee -a "$log_file"; then
    log_info "Logs fetched successfully."
else
    log_error "Failed to fetch logs"
    exit 1
fi

log_info "Process completed."
