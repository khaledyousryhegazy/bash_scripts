#!/usr/bin/env bash

set -euo pipefail

log_file="./log_process/process.log"

echo "==========Starting Disk Monitoring==========" >> "$log_file"

log_info(){
    echo "[*][INFO] $1" | tee -a "$log_file"
}

log_error(){
    echo "[*][ERROR] $1" | tee -a "$log_file"
}

remote_user=""
server_name=""

while getopts "u:s:" opt; do
    case "${opt}" in
        u) remote_user="${OPTARG}";;
        s) server_name="${OPTARG}";;
        \?) log_error "Invalid Option"; exit 1;;
        *) log_error "Something goes wrong";exit 1;;
    esac
done

if [[ -z "$remote_user" || -z "$server_name" ]]; then
    log_error "Missing Arguments"
    exit 1
fi

log_info "Start creating SSH connection and get the disk health ..."
disk_info=$(
ssh -t -q -o ConnectTimeout=5 "${remote_user}@${server_name}" "bash -s" <<'KLD'
df --si --total | awk 'END {print "Total Disk: " $2 " , " "Usage: "$3 " , " "Disk Usage Percent: " $5}'
KLD
)

echo "$disk_info" | tee -a "$log_file"

if [[ $? = 0 ]]; then
    log_info "Process completed"
else
    log_error "Something goes wrong"
fi