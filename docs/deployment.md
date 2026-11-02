# Deployment

## Prerequisites
- Terraform >= 1.6, Azure CLI, Azure subscription and permissions to create RG, VNet, Storage, Private Endpoint and Private DNS resources.

## Configure and deploy
```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit subscription_id and desired settings
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Review the plan before applying. The deployment creates billable Azure resources.

## Remote state
Bootstrap a separate state Resource Group, Storage Account and container. Enable blob versioning and soft delete, restrict data-plane access, and use Entra ID authentication. Copy `backend.tf.example` to `backend.tf`, update values and run `terraform init -reconfigure`. Grant the deployment identity appropriate Storage Blob Data permissions. Do not store backend secrets in source control.

## Verify
```bash
terraform output
az network private-endpoint list -g "<RESOURCE_GROUP>" -o table
nslookup "<ACCOUNT>.blob.core.windows.net"
```
Run DNS and data-access tests from a client with connectivity to the VNet and the correct data-plane RBAC role. DNS resolution alone does not prove authorization.

## Destroy
```bash
terraform plan -destroy
terraform destroy
```
Back up data and confirm retention requirements before destroying the Storage Account.
