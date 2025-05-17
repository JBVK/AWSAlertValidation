import time


def lambda_handler(event, context):
    time.sleep(25)

    return {"statusCode": 200, "body": "Test completed successfully."}
