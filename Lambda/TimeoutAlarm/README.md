# AWS Lambda Timeout Alert (Terraform Example)

This repository provides a Terraform-based example to deploy an AWS Lambda function designed to trigger a timeout
alarm. It is part of the blog post [AWS Alert Validation - Lambda](https://medium.com/p/13ad4842aadd).

## Table of Contents

- [Overview & Purpose](#overview--purpose)
- [Repository Structure](#repository-structure)
- [Requirements & Dependencies](#requirements--dependencies)
  - [Terraform Versions](#terraform-versions)
  - [Dependencies](#dependencies)
- [Terraform Usage](#terraform-usage)
- [Python Code Documentation](#python-code-documentation)
- [How to Trigger Timeout](#how-to-trigger-timeout)
- [License](#license)

## Overview & Purpose

This project demonstrates how to validate and test AWS Lambda timeout alarms by deploying a Lambda function with
code set to timeout.

Terraform is used to provision:

- An AWS Lambda function written in Python
- An IAM role and policy for Lambda logging
- A CloudWatch log group

## Repository Structure

```plaintext
.
├── TimeoutAlert.py      # Python Lambda function that simulates processing with a 15-second sleep
├── TimeoutAlert.zip     # Generated zip file for Lambda deployment (created by Terraform)
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

The TimeoutAlarm.py file is a simple Python script intended for use in an AWS Lambda function. Its purpose is to simulate a Lambda function to timeout to help test timeout alarm scenarios.

```python
import time


def lambda_handler(event, context):
    time.sleep(25)

    return {"statusCode": 200, "body": "Test completed successfully."}

```

- Running the `lambda_handler` function will cause the Lambda to timeout after 15 seconds.

## How to Trigger Timeout

Run the following command in a terminal:

```bash
aws lambda invoke --function-name <function_name> outfile
```

Replace `<function_name>` with the name of the Lambda function created by Terraform. This will invoke the function and trigger an timeout.

## License

This project is licensed under the MIT License. See the [LICENSE](../../LICENSE) file for details.
