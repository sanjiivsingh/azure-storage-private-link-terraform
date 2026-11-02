# Azure Storage Private Link with Terraform

[![Status](https://img.shields.io/badge/Status-Statically%20Validated-informational.svg)](docs/EVIDENCE.md)
[![Terraform CI](https://github.com/sanjiivsingh/azure-storage-private-link-terraform/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/sanjiivsingh/azure-storage-private-link-terraform/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D%201.6.0-844FBA?logo=terraform&logoColor=white)](https://www.terraform.io)
[![AzureRM](https://img.shields.io/badge/AzureRM-~%3E%204.0-0078D4?logo=microsoftazure&logoColor=white)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![Security](https://img.shields.io/badge/Checkov-Passing-brightgreen?logo=prismacloud&logoColor=white)](checkov.yaml)

A production-grade, modular Terraform reference architecture establishing **zero-public-access Azure Storage** via **Azure Private Link, dedicated Private Endpoints, and Private DNS Zone Groups**.

This platform provisions an isolated spoke Virtual Network with a dedicated Private Endpoint subnet, a hardened Azure Storage Account (Blob, File, Queue, Table), and automatically manages the DNS CNAME delegation chain for transparent, private-only data access without exposed public endpoints or storage access keys.

---

## 🏛️ Architecture Overview

```mermaid
flowchart TB
  subgraph SpokeVNet["Spoke Virtual Network (10.40.0.0/16)"]
    direction TB
    Workload["Private Workload Subnet<br/>(VMs / AKS / Container Apps)"]
    
    subgraph PESubnet["Private Endpoint Subnet (10.40.10.0/24)"]
      BlobPE["Blob Private Endpoint<br/><code>10.40.10.4</code>"]
      FilePE["File Private Endpoint<br/><code>10.40.10.5</code>"]
      QueuePE["Queue Private Endpoint<br/><code>10.40.10.6</code>"]
      TablePE["Table Private Endpoint<br/><code>10.40.10.7</code>"]
    end
  end

  subgraph StorageAccount["Azure Storage Account (Zero-Public Access)"]
    SA["Standard Storage Account<br/>• Public Network Access: Disabled<br/>• Shared Key Auth: Disabled<br/>• Default Action: Deny<br/>• TLS 1.2+ HTTPS Only"]
  end

  subgraph DNSZones["Azure Private DNS Zones"]
    BlobDNS["privatelink.blob.core.windows.net"]
    FileDNS["privatelink.file.core.windows.net"]
    QueueDNS["privatelink.queue.core.windows.net"]
    TableDNS["privatelink.table.core.windows.net"]
  end

  Workload --> PESubnet
  BlobPE --> SA
  FilePE --> SA
  QueuePE --> SA
  TablePE --> SA

  BlobPE -.->|A Record Registration| BlobDNS
  FilePE -.->|A Record Registration| FileDNS
  QueuePE -.->|A Record Registration| QueueDNS
  TablePE -.->|A Record Registration| TableDNS

  BlobDNS ---|VNet Link| SpokeVNet
  FileDNS ---|VNet Link| SpokeVNet
  QueueDNS ---|VNet Link| SpokeVNet
  TableDNS ---|VNet Link| SpokeVNet

  classDef vnet fill:#f8fafc,stroke:#0284c7,stroke-width:2px;
  classDef pe fill:#f0fdf4,stroke:#16a34a,stroke-width:1.5px;
  classDef storage fill:#fef2f2,stroke:#dc2626,stroke-width:2px;
  classDef dns fill:#f5f3ff,stroke:#7c3aed,stroke-width:1.5px;

  class SpokeVNet,PESubnet vnet;
  class BlobPE,FilePE,QueuePE,TablePE pe;
  class SA,StorageAccount storage;
  class BlobDNS,FileDNS,QueueDNS,TableDNS,DNSZones dns;
```

---

## 🔄 Private DNS Resolution Sequence

When client workloads in the spoke VNet make requests to standard public FQDNs (e.g. `storageaccount.blob.core.windows.net`), the resolution follows an automatic CNAME alias chain to the Private Link IP:

```mermaid
sequenceDiagram
  autonumber
  actor Client as Client App (VNet)
  participant DNS as Azure Recursive Resolver (168.63.129.16)
  participant PubDNS as Public Azure DNS
  participant PrivDNS as Private DNS Zone (privatelink.blob.core.windows.net)
  participant PE as Private Endpoint NIC (10.40.10.4)
  participant Storage as Storage Account Backend

  Client->>DNS: Query storageaccount.blob.core.windows.net
  DNS->>PubDNS: Resolve public CNAME
  PubDNS-->>DNS: CNAME storageaccount.privatelink.blob.core.windows.net
  DNS->>PrivDNS: Resolve privatelink CNAME via VNet Link
  PrivDNS-->>DNS: A Record -> 10.40.10.4
  DNS-->>Client: Returns 10.40.10.4 (Private IP)
  Client->>PE: HTTPS TLS 1.2 Handshake (Host: storageaccount.blob.core.windows.net)
  PE->>Storage: Encrypted Azure Backbone Routing
  Storage-->>Client: Data Access Success (Entra ID RBAC Authorized)
```

---

## 📁 Repository Structure

```text
azure-storage-private-link-terraform/
├── .github/
│   └── workflows/
│       └── terraform-ci.yml           # Automated CI: fmt, validate, tflint, checkov, gitleaks
├── diagrams/
│   ├── architecture.mmd               # Architecture flowchart definition
│   └── dns-resolution.mmd             # DNS sequence diagram definition
├── docs/
│   ├── ADR/
│   │   └── 0001-per-subresource-private-endpoints.md # Architecture Decision Record
│   ├── architecture.md                # System topology and subnet sizing
│   ├── deployment.md                  # Deployment steps and backend configuration
│   ├── dns-and-private-link.md        # DNS delegation and hybrid forwarding patterns
│   ├── operations-and-troubleshooting.md # KQL queries, routing validation, DNS debugging
│   ├── security-and-best-practices.md # Zero-Trust compliance and Entra ID RBAC
│   └── EVIDENCE.md                    # Verification records and static analysis audit
├── environments/
│   └── dev/
│       ├── main.tf                    # Environment root composition
│       ├── variables.tf               # Parameter declarations with type validation
│       ├── outputs.tf                 # Exported resource IDs, endpoints, and IPs
│       ├── providers.tf               # Provider requirements (azurerm ~> 4.0, random ~> 3.6)
│       ├── backend.tf.example         # Production remote state template
│       └── terraform.tfvars.example   # Example parameter values
├── modules/
│   ├── networking/                    # Spoke VNet and dedicated PE subnet
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── storage/                       # Hardened Storage Account with soft delete & OAuth
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── private-endpoint/              # PE per subresource and Private DNS zone group
│       ├── main.tf
│       ├── locals.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── .gitignore
├── .tflint.hcl                        # TFLint ruleset configuration
├── checkov.yaml                       # Static analysis security baseline configuration
├── LICENSE                            # MIT License
└── README.md
```

---

## 🔒 Enterprise Security Guardrails

| Control Area | Implementation Details | CIS Azure Benchmark |
| :--- | :--- | :---: |
| **Public Network Access** | Explicitly disabled (`public_network_access_enabled = false`). All public IPs rejected at the edge. | CIS 5.1 |
| **Network Rule Action** | Default action set to `Deny` with `AzureServices` bypass for platform monitoring. | CIS 5.2 |
| **Authentication Model** | Storage shared access keys disabled (`shared_access_key_enabled = false`). OAuth default enabled (`default_to_oauth_authentication = true`). Access strictly governed by Microsoft Entra ID RBAC. | CIS 5.3 |
| **Transport Encryption** | Minimum TLS version constrained to `TLS1_2`. HTTPS-only traffic enforced. | CIS 5.4 |
| **Data Retention** | Blob versioning enabled with 7-day soft delete retention for both blobs and containers. | CIS 5.5 |
| **SAS Expiration Policy** | Explicit SAS policy configured with 90-day expiration limit and audit logging. | CKV2_AZURE_41 |
| **DNS Split-Brain Defense** | `private_dns_zone_group` configures automated Azure-managed dynamic A records directly upon endpoint provisioning. | CAF Best Practice |

---

## 🚀 Quickstart & Deployment

### Prerequisites
- [Terraform](https://www.terraform.io/) `>= 1.6.0` (Recommended `>= 1.9.0`)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) `>= 2.50.0`
- Contributor / Owner permissions on the target Azure Subscription

### Local Deployment

```bash
# 1. Clone repository
git clone https://github.com/sanjiivsingh/azure-storage-private-link-terraform.git
cd azure-storage-private-link-terraform/environments/dev

# 2. Authenticate to Azure CLI
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"

# 3. Configure parameters
cp terraform.tfvars.example terraform.tfvars
# Update subscription_id, location, and name_prefix in terraform.tfvars

# 4. Initialize Terraform
terraform init

# 5. Format and validate
terraform fmt -recursive
terraform validate

# 6. Execute Plan & Apply
terraform plan -out=tfplan
terraform apply tfplan
```

### Production Remote State
For enterprise production environments, configure the Azure Blob remote backend:
1. Rename `backend.tf.example` to `backend.tf`.
2. Populate `resource_group_name`, `storage_account_name`, `container_name`, and `key`.
3. Reinitialize: `terraform init -migrate-state`.

---

## 🧪 Quality Gates & CI Pipeline

Every push and pull request executes an automated verification pipeline defined in [`.github/workflows/terraform-ci.yml`](.github/workflows/terraform-ci.yml):

```bash
# Run formatting check
terraform fmt -check -recursive

# Validate environment syntax
cd environments/dev && terraform init -backend=false && terraform validate && cd ../..

# Run TFLint across all modules
tflint --init && tflint --recursive

# Run Checkov static security analysis
checkov -d . --config-file checkov.yaml

# Run Gitleaks credential detection
gitleaks dir . -v
```

Audit logs and reproduction instructions are documented in [docs/EVIDENCE.md](docs/EVIDENCE.md).

---

## 📚 Architectural Decision Records & Documentation

- [docs/ADR/0001-per-subresource-private-endpoints.md](docs/ADR/0001-per-subresource-private-endpoints.md) - Rationale for distinct Private Endpoints per storage subresource.
- [docs/architecture.md](docs/architecture.md) - Subnet sizing, hub-and-spoke topology integration.
- [docs/dns-and-private-link.md](docs/dns-and-private-link.md) - Private DNS zone groups and hybrid resolver patterns.
- [docs/security-and-best-practices.md](docs/security-and-best-practices.md) - Microsoft Entra ID RBAC roles and Zero-Trust architecture.
- [docs/operations-and-troubleshooting.md](docs/operations-and-troubleshooting.md) - Connection troubleshooting and KQL monitoring queries.
- [docs/deployment.md](docs/deployment.md) - Step-by-step production rollout guide.

---

## 👤 Author & Architecture Inquiries

**Sanjeev Singh**  
*Senior Azure Cloud Architect & DevSecOps Platform Engineer*  
- **Portfolio**: [sanjeevsingh.oneps.in](https://sanjeevsingh.oneps.in)  
- **GitHub**: [@sanjiivsingh](https://github.com/sanjiivsingh)  
- **Case Study**: [Trading Platform Infrastructure Case Study](https://github.com/sanjiivsingh/sanjiivsingh/blob/main/case-studies/trading-platform.md)  
- **Contact**: [Submit Project Inquiry](https://sanjeevsingh.oneps.in/#contact)

---

## 📄 License

This reference architecture is open-source under the [MIT License](LICENSE).
