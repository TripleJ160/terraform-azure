# Azure Resource Group Terraform Project

This project uses Terraform to provision an Azure Resource Group with basic configuration.

## Prerequisites

- Terraform (v1.11.4 or later)
- Azure CLI
- Azure subscription

## Resources Created

- Azure Resource Group named "jjj-resources" in East US region with dev environment tag

## Getting Started

1. Login to Azure:
```sh
az login
```

2. Initialize Terraform:
```sh
terraform init
```

3. Review planned changes:
```sh
terraform plan
```

4. Apply the configuration:
```sh
terraform apply
```

## Project Structure

- `main.tf` - Main Terraform configuration file
- `.gitignore` - Git ignore patterns for Terraform files
- `terraform.tfstate` - Terraform state file (do not edit manually)

## Provider Configuration

This project uses the Azure provider (`hashicorp/azurerm`) version ~> 3.0.

## License

This project is licensed under the Mozilla Public License Version 2.0.