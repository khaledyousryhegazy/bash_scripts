#!/usr/bin/env bash

set -euo pipefail

mkdir -p ./logs
mkdir -p ./backups

log_file="./logs/backup.log"

log_info(){
    echo "[*][INFO] $1" | tee -a "${log_file}"
}

log_error(){
    echo "[*][ERROR] $1" | tee -a "${log_file}"
}

print_usage(){
    echo "[*][USAGE] $0 -u <remote_user> -s <servers_file> -p <remote_dir_or_file>"
}

# create backup function
create_backup() {
    local user="$1"
    local server="$2"
    local data_path="$3"
    local backup_path="$(realpath ./backups)"
    
    if [[ -z "${user}" || -z "${server}" ]];then
        log_error "Please make sure that you entered the user and the server."
        exit 1
    fi
    
    # check if rsync exits and if not install it
    
    if ! command -v rsync &> /dev/null ; then
        echo "rsync command not found,  install it ?"
        
        echo "[*] 1 -> Yes"
        echo "[*] 2 -> No"
        
        read answer
        
        if [ "${answer}" -eq 1 ] ; then
            source /etc/os-release
            case "$ID" in
                arch) sudo pacman -Sy rsync ;;
                debian|ubuntu) sudo apt install -y rsync ;;
                fedora) sudo dnf install -y rsync ;;
                *) log_error "Unsupported OS"; exit 1;;
            esac
            
        else
            log_error "please install rsync command first"
            exit 1
        fi
    fi
    
    current_date=$(date +%Y-%m-%d)
    
    mkdir -p "$backup_path/$current_date"
    
    mkdir -p "$backup_path/current"
    
    # rsync_options=(
    #     -avz
    #     --delete
    #     --backup
    #     --backup-dir="$backup_path/$current_date"
    # )
    rsync_options="-avb --backup-dir $backup_path/$current_date --delete"
    rsync ${rsync_options[@]} \
    "${user}@${server}:${data_path}" \
    "${backup_path}/current" 2>&1 | tee -a "${log_file}"
}

# main function
main() {
    log_info "Starting backup process"
    remote_user=""
    servers_file=""
    data_path=""
    
    while getopts "u:s:p:h" opt; do
        case $opt in
            u) remote_user="${OPTARG}";;
            s) servers_file="${OPTARG}";;
            p) data_path="${OPTARG}";;
            h) print_usage; exit 0;;
            \?) echo "Invalid options"; exit 1;;
            :) echo "Missing argument"; exit 1;;
            *) echo "Something goes wrong"; exit 1;;
        esac
    done
    
    if [[ -z "${remote_user}" || -z "${servers_file}" || -z "${data_path}" ]]; then
        log_error "Missing arguments, Please try again."
        print_usage
        exit 1
    fi
    
    declare -a servers=()
    
    while IFS= read -r line; do
        [[ -z "${line}" || "${line}" == \#* ]] && continue
        servers+=("${line}")
    done < "${servers_file}"
    
    log_info "Found ${#servers[@]} servers, Start Checking ..."
    
    for server in "${servers[@]}"; do
        create_backup "${remote_user}" "${server}" "${data_path}"
    done
    
    log_info "Process completed Successfully."
}

main "$@"