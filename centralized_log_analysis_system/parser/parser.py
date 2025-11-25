import os
import sys
import re
import json
import logging
from pathlib import Path
from collections import Counter
from typing import Any

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(BASE_DIR)
sys.path.append(BASE_DIR)


logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] [%(levelname)s] [*] %(message)s",
    handlers=[logging.FileHandler("../log_process/process.log")],
)

logger = logging.getLogger(__name__)

os.makedirs("../reports", exist_ok=True)

logger.info("==========Starting parse file==========")


def parser_log_files() -> None:
    logger.info("Start loop on files to extract info and store it in json files ..")
    log_files_path = Path("../logs/")
    patterns = {
        "error_count": r"error",
        "warnings_count": r"warning",
        "failed_login_attempts_count": r"Failed password",
        "accepted_login_attempts_count": r"Accepted password",
        "successful_requests": r"200",
        "unauth_requests": r"401",
        "server_error_requests": r"500",
        "get_requests_count": r"get",
        "post_requests_count": r"post",
    }
    ip_pattern = r"\b(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\b"

    for log_file in os.listdir(log_files_path):
        try:
            full_file_path = log_files_path / log_file
            json_data: dict[str, Any] = {key: 0 for key in patterns}
            ip_addresses: list[str] = []

            logger.info(f"Parsing {log_file} file")

            with open(full_file_path, "r", encoding="utf-8") as file:
                for line in file:

                    for key, pattern in patterns.items():
                        if re.search(pattern, line, re.IGNORECASE):
                            json_data[key] += 1

                    ips = re.findall(ip_pattern, line)
                    ip_addresses.extend(ips)

            counts = Counter(ip_addresses)
            most_common = counts.most_common(1)

            if most_common:
                most_frequent_ip, count = most_common[0]
                if count > 3:
                    json_data["most_frequent_ip"] = {most_frequent_ip: count}

            with open(
                f"../reports/{Path(log_file).stem}.json", "w", encoding="utf-8"
            ) as fjson:
                json.dump(json_data, fjson, ensure_ascii=False, indent=4)

        except Exception as e:
            logger.error(f"Error processing {log_file}: {e}")  # type:ignore

    logger.info("Process completed successfully.")


parser_log_files()
