# AWS Lambda DLQ Alarm (Terraform Example)

This repository provides a Terraform-based example to deploy an AWS Lambda function designed to fail and send messages to a Dead Letter Queue (DLQ).
It is part of the blog post [AWS Alert Validation - Lambda](https://medium.com/p/13ad4842aadd).

## Table of Contents

- [Overview & Purpose](#overview--purpose)
- [Repository Structure](#repository-structure)
- [Requirements & Dependencies](#requirements--dependencies)
  - [Terraform Versions](#terraform-versions)
  - [Dependencies](#dependencies)
- [Terraform Usage](#terraform-usage)
- [Python Code Documentation](#python-code-documentation)
- [How to Trigger DLQ Message](#how-to-trigger-throttling)
- [License](#license)

## Overview & Purpose

This project demonstrates how to validate and test AWS Lambda DLQ alarms by deploying a Lambda function with code set to raise an exception.
The failure will trigger the DLQ, allowing you to test the alerting mechanism.

Terraform is used to provision:

- An AWS Lambda function written in Python
- An IAM role and policy for Lambda logging
- A CloudWatch log group
- A Dead Letter Queue (DLQ) for the Lambda function

## Repository Structure

```plaintext
.
├── DLQAlarm.py               # Python Lambda function that simulates a failure sending event to DLQ
├── DLQAlarm.zip              # Generated zip file for Lambda deployment (created by Terraform)
├── main.tf                   # Terraform configuration for Lambda, IAM, and CloudWatch
├── terraform.tf              # Terraform provider versions and required Terraform version
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

After deployment, you need to remove the permissions for the Lambda function to send messages to the DLQ. This is done by removing the `sqs:SendMessage` permission from the Lambda function's execution role. This will mimick a failure in sending messages to the DLQ.

Then you can trigger the Lambda to simulate a failure.

````bash

## Python Code Documentation

The DLQAlarm.py file is a simple Python script intended for use in an AWS Lambda function. Its purpose is to simulate a failing Lambda function to help test DLQ alarm scenarios.

```python
def lambda_handler(event, context):
    raise Exception("Triggered error alarm for testing purposes.")

````

- Raising an exception simulates a failure in the Lambda function.
- The Lambda function is configured to send failed events to a Dead Letter Queue (DLQ) for further processing.

## How to Trigger Error

Run the following command in a terminal:

```bash
aws lambda invoke --function-name <function_name> --invocation-type Event output.json
```

Replace `<function_name>` with the name of the Lambda function created by Terraform. This will invoke the function and trigger throttling due to the reserved concurrency limit.

## License

This project is licensed under the MIT License. See the [LICENSE](../../LICENSE) file for details.
