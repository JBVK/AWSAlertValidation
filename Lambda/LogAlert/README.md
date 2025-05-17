# AWS Lambda Log Alert (Terraform Example)

This repository provides a Terraform-based example to deploy an AWS Lambda function designed to log a message and trigger a
log alarm. It is part of the blog post [AWS Alert Validation - Lambda](https://medium.com/p/13ad4842aadd).

## Table of Contents

- [Overview & Purpose](#overview--purpose)
- [Repository Structure](#repository-structure)
- [Requirements & Dependencies](#requirements--dependencies)
  - [Terraform Versions](#terraform-versions)
  - [Dependencies](#dependencies)
- [Terraform Usage](#terraform-usage)
- [Python Code Documentation](#python-code-documentation)
- [How to Trigger Log Alert](#how-to-trigger-log-alert)
- [License](#license)

## Overview & Purpose

This project demonstrates how to validate and test AWS Lambda log alarms by deploying a Lambda function with
code set to log a message that is monitored by CloudWatch.

Terraform is used to provision:

- An AWS Lambda function written in Python
- An IAM role and policy for Lambda logging
- A CloudWatch log group

## Repository Structure

```plaintext
.
├── ErrorAlert.py        # Python Lambda function that simulates processing with a 15-second sleep
├── ErrorAlert.zip       # Generated zip file for Lambda deployment (created by Terraform)
├── main.tf              # Terraform configuration for Lambda, IAM, and CloudWatch
├── terraform.tf         # Terraform provider versions and required Terraform version
```

## Requirements & Dependencies

### Terraform Versions

- Terraform `>= 1.11.0`
- AWS Provider `~> 5.97.0`
- Archive Provider `~> 2.7.1`

### Dependencies

- AWS CLI configured with valid credentials
- Python 3.12 runtime (used by the Lambda)
- No required variables — this module runs as-is

## Terraform Usage

There are no variables to configure in this example. Simply initialize and apply:

```bash
terraform init
terraform apply
```

After deployment, you can trigger the Lambda to simulate throttling.

## Python Code Documentation

The LogAlarm.py file is a simple Python script intended for use in an AWS Lambda function. Its purpose is to log a message to CloudWatch logs to help test log alarm scenarios.
The script uses the `logging` module to log a message at the INFO level. The log message is retrieved from an environment variable named `LOG_LINE`, which can be set in the Lambda function configuration. If not set, it defaults to "This is a test log line.".

```python
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logline = os.environ.get("LOG_LINE", "This is a test log line.")
    logging.info(logline)

    return {"statusCode": 200, "body": "Test completed successfully."}

```

- Raising an exception simulates a failure in the Lambda function.

## How to Trigger Log Alert

Run the following command in a terminal:

```bash
aws lambda invoke --function-name <function_name> outfile
```

Replace `<function_name>` with the name of the Lambda function created by Terraform. This will invoke the function and write the log line to the logs making the logalert to trigger.

## License

This project is licensed under the MIT License. See the [LICENSE](../../LICENSE) file for details.
