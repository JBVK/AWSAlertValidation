# AWS Lambda Throttling Alert (Terraform Example)

This repository provides a Terraform-based example to deploy an AWS Lambda function designed to trigger a error
alarm. It is part of the blog post [AWS Alert Validation - Lambda](https://medium.com/p/13ad4842aadd).

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

This project demonstrates how to validate and test AWS Lambda error alarms by deploying a Lambda function with
code set to raise an exception.

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

The ErrorAlarm.py file is a simple Python script intended for use in an AWS Lambda function. Its purpose is to simulate a failing Lambda function to help test error alarm scenarios.

```python
def lambda_handler(event, context):
    raise Exception("Triggered error alarm for testing purposes.")
```

- Raising an exception simulates a failure in the Lambda function.

## How to Trigger Throttling

Run the following command in a terminal:

```bash
aws lambda invoke --function-name <function_name> outfile
```

Replace `<function_name>` with the name of the Lambda function created by Terraform. This will invoke the function and trigger an error.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
