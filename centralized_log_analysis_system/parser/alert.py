import sys
import os
import logging
from dotenv import load_dotenv
from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(BASE_DIR)
sys.path.append(BASE_DIR)

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] [%(levelname)s] [*] %(message)s",
    handlers=[logging.FileHandler("../log_process/process.log")],
)

logger = logging.getLogger(__name__)

logger.info("==========Start sending message==========")


def send_alert(message: str) -> None:
    client = WebClient(token=os.getenv("SLACK_BOT_TOKEN"))

    try:
        client.chat_postMessage(  # type:ignore
            channel="#all-devops", text=message
        )
        logger.info(f"Message {message} sended successfully")
    except SlackApiError as e:
        logger.error(f"Slack api error: {e}")
    logger.info("Process completed")
