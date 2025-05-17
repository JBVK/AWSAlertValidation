import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logline = os.environ.get("LOG_LINE", "This is a test log line.")
    logging.info(logline)

    return {"statusCode": 200, "body": "Test completed successfully."}
