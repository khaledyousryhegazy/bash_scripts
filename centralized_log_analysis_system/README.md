# Centralized Log Analysis System

A simple Bash + Python project to fetch system log files from remote servers, parse them, and generate a JSON files for analysis.

## 📌 Features

- Fetch `.log` files from remote servers using `rsync`
- Disk health `monitoring`
- Parse log files and extract `json` files with info
- Send `alerts` to slack with number of errors and failed login attempts

## 📁 Project Structure

```bash
centralized_log_analysis_system/
│
├── scripts/
│ └── fetch_logs.sh # get the log files from the server
│ └── disk_monitor.sh # get the disk health from the server
│
├── parser/
│ └── parse_logs.py # parsing the log files , create a json files and store the info in it
│ └── alert.py # setup fo the notification sys to slack
│ └── send_messages.py # take the message text and send a message to slack
│
├── logs/ # the received log files from the server
│
├── cron_jobs # have the schema to running the script with crontab
│
├── log_process # contain the steps/results of the process in the file process.log
│
│
└── reports # contain the json files of the logs file (the result of parsing)
```

## 🚀 Usage

### main.sh

```bash
./main.sh -u <remote_user> -s <server_address> -p <log_path>
```
