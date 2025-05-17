# AWS Lambda Throttling Alert (Terraform Example)

This repository provides a Terraform-based example to deploy an AWS Lambda function designed to trigger a throttling
alarm. It is part of the blog post [AWS Alert Validation - Lambda](https://medium.com/p/13ad4842aadd). The Lambda is
intentionally configured to allow throttling by limiting its concurrency and simulating long execution.

## Table of Contents

- [Overview & Purpose](#overview--purpose)
- [Repository Structure](#repository-structure)
- [Requirements & Dependencies](#requirements--dependencies)
  - [Terraform Versions](#terraform-versions)
  - [Dependencies](#dependencies)
- [Terraform Usage](#terraform-usage)
- [Python Code Documentation](#python-code-documentation)
- [How to Trigger Throttling](#how-to-trigger-throttling)
- [License](#license)

## Overview & Purpose

This project demonstrates how to validate and test AWS Lambda throttling alarms by deploying a Lambda function with
reserved concurrency set to 1. By invoking the function concurrently from multiple terminals, you can trigger throttling
and validate alarm configurations.

Terraform is used to provision:

- An AWS Lambda function written in Python
- An IAM role and policy for Lambda logging
- A CloudWatch log group

## Repository Structure

```plaintext
.
├── ThrottlingAlert.py        # Python Lambda function that simulates processing with a 15-second sleep
├── ThrottlingAlert.zip       # Generated zip file for Lambda deployment (created by Terraform)
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

After deployment, you can trigger the Lambda to simulate throttling.

## Python Code Documentation

The ThrottlingAlert.py file is a simple Python script intended for use in an AWS Lambda function. Its purpose is to simulate a long-running process to help test throttling scenarios.

```python
def lambda_handler(event, context):
    time.sleep(15)
    return {"statusCode": 200, "body": "Test completed successfully."}
```

- Sleeps for 15 seconds to allow multiple invocations to overlap
- Used in conjunction with reserved_concurrent_executions = 1 to force throttling

## How to Trigger Throttling

Run the following command in multiple terminals simultaneously:

```bash
aws lambda invoke --function-name <function_name> outfile
```

Replace `<function_name>` with the name of the Lambda function created by Terraform. This will invoke the function and trigger throttling due to the reserved concurrency limit.

## License

This project is licensed under the MIT License. See the [LICENSE](../../LICENSE) file for details.
