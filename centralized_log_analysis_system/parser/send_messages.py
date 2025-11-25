import os
import sys
import json
from pathlib import Path
from alert import send_alert

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(BASE_DIR)
sys.path.append(BASE_DIR)


def send_messages():
    dir_path = Path("../reports/")
    for json_file in os.listdir(dir_path):
        file_path = dir_path / Path(json_file)
        with open(file_path, "r", encoding="utf-8") as file:
            data = json.load(file)
            for k, v in data.items():
                if k == "error_count" and v >= 10:
                    send_alert(f"The Error Count Is {v} in {json_file}")
                elif k == "failed_login_attempts_count" and v >= 10:
                    send_alert(f"There's {v} Failed Login Attempts")


send_messages()
