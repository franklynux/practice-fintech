# Fintech-Infra

Secure Terraform Backend with Multi-Region State Management

## Story Overview

This infrastructure implements a secure Terraform remote backend with S3 state storage and DynamoDB state locking across multiple AWS regions (us-east-1, eu-west-1, eu-west-2). The setup ensures safe collaborative infrastructure management with proper isolation and disaster recovery capabilities.

## Architecture

- **Bootstrap Module**: Creates S3 buckets and DynamoDB tables for backend infrastructure
- **Multi-Region Setup**: Separate state storage for us-east-1, eu-west-1, and eu-west-2
- **Regional Isolation**: Each region has dedicated folders under `environments/` for better security and performance
- **State Protection**: Lifecycle policies prevent accidental destruction of critical resources

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- IAM permissions for S3, DynamoDB across target regions
- Access to create resources in us-east-1, eu-west-1, and eu-west-2

## Project Structure

```
├── main.tf                    # Root configuration
├── variables.tf               # Input variables
├── terraform/
│   ├── bootstrap/            # Backend infrastructure module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── environments/          # Regional state isolation
│       ├── us-east-1/
│       │   ├── main.tf
│       │   └── backend.tf
│       ├── eu-west-1/
│       │   ├── main.tf
│       │   └── backend.tf
│       └── eu-west-2/
│           ├── main.tf
│           └── backend.tf
└── .gitignore
```

## Setup Instructions

### Step 1: Deploy Bootstrap Infrastructure (Root Directory)

```bash
# From root directory
terraform init
terraform validate
terraform plan
terraform apply
```

This creates S3 buckets and DynamoDB tables for all three regions using default variable values from `terraform/bootstrap/variables.tf`.

### Step 2: Configure Regional Backends

After bootstrap deployment, initialize each regional backend:

#### For us-east-1

```bash
cd terraform/environments/us-east-1
terraform init
terraform apply
```

#### For eu-west-1

```bash
cd terraform/environments/eu-west-1
terraform init
terraform apply
```

#### For eu-west-2

```bash
cd terraform/environments/eu-west-2
terraform init
terraform apply
```

## Backend Configuration

Each regional environment uses its dedicated backend:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-state-s3-bucket-name-{region}"
    key            = "terraform.tfstate"
    region         = "{target-region}"
    dynamodb_table = "dynamodb-statelock-name-{region}"
    role_arn       = "arn:aws:iam::xxxx:role/OrganizationAccountAccessRole"
    encrypt        = true
    profile        = "assigned-aws-profile"
  }
}
```

## Security Features

- **S3 Bucket Protection**: Versioning enabled, public access blocked
- **DynamoDB Protection**: Deletion protection enabled
- **Lifecycle Rules**: `prevent_destroy = true` on critical resources
- **Encryption**: State files encrypted at rest
- **Access Control**: Proper IAM policies for secure access

## Usage Guidelines

1. Always run `terraform plan` before `terraform apply`
2. For faster deployment use the flag '-auto-approve' with the `terraform apply` cmd, but use with caution. Ensure you review the plan output first.
3. Use appropriate regional directory for a target region
4. State locking prevents concurrent modifications automatically
5. S3 bucket names must be globally unique
6. Backend migration is one-time setup after initial deployment

## Troubleshooting

- **Bucket name conflicts**: Ensure globally unique bucket names
- **Permission errors**: Verify IAM permissions for target regions
- **State lock issues**: Check DynamoDB table accessibility
- **Backend migration**: Use `terraform init -migrate-state` if needed

## Benefits of Isolated multi-region state management over a single region state management or Terraform Workspaces

- **Regional Isolation & Security**: Isolation of multi-region state management allows for better compliance and data residency. It meets legal requirements ( e.g EU data must stay within EU, UK data must stay within UK).
- **Disaster Recovery**: If one region goes down, others remain unaffected and keep operating.
- **Performance & Latency**: Multi-region state management approach favours teams working with infrastructure geographically closer to them, reducing latency for terraform ops.
- **Cost Management**: Optimizes costs by localizing resources per region and reducing cross-region data transfer fees, and also gives clearer cost seperation by geography & business unit.
- **Access Control**: Allows for fine-grained permissions per region.
Shared infrastructure: Terraform, CI/CD pipelines, networking


## Add Security Scanning Hooks to Project Repos - Security Scans Workflow (Trivy)

This project includes a GitHub Actions workflow for automated security scanning using **Trivy**. The workflow is triggered automatically on every **push** and **pull request** to any branch.

## Workflow Overview - The workflow is configured in yaml 

The workflow performs multiple types of security scans to ensure the repository and its configuration are safe from vulnerabilities and misconfigurations. The main steps are:

1. **Checkout Repository**  
   The workflow starts by checking out the repository code using `actions/checkout@v4`.

2. **Install Trivy**  
   Trivy is installed on the runner using the official Aquasecurity repository. Required dependencies (`wget`, `apt-transport-https`, etc.) are installed to enable Trivy installation.

3. **Cache Trivy Database**  
   Trivy downloads a vulnerability database to detect security issues. The workflow caches this database (`~/.cache/trivy`) between runs to speed up subsequent scans.

4. **Secret Scanning**  
   Trivy scans the filesystem (`trivy fs`) for **secrets** such as API keys or credentials, focusing on **high** and **critical** severity. If any issues are found, the workflow fails with `--exit-code 1`.

5. **Vulnerability Scanning**  
   The workflow scans for **high and critical vulnerabilities** in dependencies, container images, and configuration files. Detected issues will fail the workflow, ensuring that vulnerabilities are caught early.

6. **Misconfiguration (PCI) Scanning**  
   Trivy also checks for **misconfigurations** in Dockerfiles, Kubernetes manifests, Terraform scripts, CloudFormation templates, YAML, and JSON files. Custom policies from the `./policies` directory are applied, with medium and higher severity issues causing the workflow to fail.

## Environment

- Runs on `ubuntu-latest` GitHub Actions runner.
- Uses `TRIVY_CACHE_DIR` to store the vulnerability database locally.

## Outcome

- If any secrets, vulnerabilities, or misconfigurations are detected at the configured severity levels, the workflow fails and prevents merging until issues are addressed.
- This ensures that code merged into the repository meets security standards and reduces the risk of introducing vulnerabilities.


