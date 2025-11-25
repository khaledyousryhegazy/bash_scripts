#!/usr/bin/env bash
set -euo pipefail

remote_user=""
server_name=""
log_path=""

print_usage() {
    echo "[USAGE] $0 -u <remote_user> -s <server_name> -p <logs_path>"
}

while getopts "u:s:p:h" opt ; do
    case "$opt" in
        u)
            remote_user="${OPTARG}"
        ;;
        s)
            server_name="${OPTARG}"
        ;;
        p)
            log_path="${OPTARG}"
        ;;
        h)
            print_usage;exit 1
        ;;
        \?)
            echo "Invalid Option ."; print_usage ; exit 1
        ;;
        *)
            echo "Something goes wrong please try again ."; print_usage ; exit 1
        ;;
    esac
done

./scripts/fetch_logs.sh -u "${remote_user}" -s "${server_name}" -p "${log_path}"

./scripts/disk_monitor.sh -u "${remote_user}" -s "${server_name}"

source .venv/bin/activate
python3 ./parser/parser.py
python3 ./parser/send_messages.py
deactivate