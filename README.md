# bash-scripts

### A collection of Bash scripts that make some processes easier :))

---

## 📋 Overview

#### This repo contains multiple of Bash scripts, each in its own folder with examples and how to use:

- server_health_checker/ → Connect with to server or multiple servers from ssh and run some commands to get some info about the each server and show it in professional way

- centralized_log_analysis_system/ → Connects to the remote server, retrieves log files from a specific directory, and transfers them to the ./logs directory using rsync. After that, the parser.py script parses the files and extracts important information into JSON files. These JSON files are then passed to the send_messages.py script, which checks the extracted data and sends alerts to Slack, in addition to creating a log file that records all steps of the process.
