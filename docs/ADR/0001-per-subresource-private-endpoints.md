# ADR-001: Distinct Private Endpoints per Storage Subresource

## Status
Accepted

## Context
Azure Storage Accounts expose multiple storage services (Blob, File, Queue, Table, DFS/Data Lake) under distinct DNS namespaces:
- Blob: `<account>.blob.core.windows.net`
- File: `<account>.file.core.windows.net`
- Queue: `<account>.queue.core.windows.net`
- Table: `<account>.table.core.windows.net`

In Azure Private Link, an `azurerm_private_endpoint` resource requires specifying target `subresource_names` inside its `private_service_connection` block. 

When deploying Private Endpoints in Terraform, there are two architectural alternatives:
1. Attempting to group multiple subresources into a single endpoint.
2. Provisioning dedicated, decoupled Private Endpoints per subresource using `for_each`.

## Decision
We decided to deploy **distinct, per-subresource Private Endpoints** using Terraform `for_each` iteration across `var.storage_subresources`.

### Key Rationale:
1. **API & Resource Lifecycle**: Azure Private Endpoints for Storage require individual IP allocations and separate Private DNS zone group mappings for each service namespace (`privatelink.blob.core.windows.net`, etc.). A single endpoint cannot dynamically join multiple incompatible DNS zone groups cleanly.
2. **Dynamic Top-Level Resources**: Terraform `dynamic` blocks can only repeat nested blocks within a single resource; they cannot instantiate multiple top-level Azure resources. Using `for_each` on `azurerm_private_endpoint` provides independent lifecycle management for each storage service.
3. **Subresource Selectivity**: Teams that only require Blob storage (or Blob + Queue) can selectively configure `var.storage_subresources = ["blob"]`, avoiding unused endpoint hourly costs and subnet IP consumption.
4. **Clean DNS Mapping**: Associating each endpoint with its dedicated Private DNS zone group (`default` group mapped to `privatelink.<service>.core.windows.net`) allows Azure to manage DNS 'A' records automatically without custom DNS automation scripts.

## Consequences
- Each enabled subresource consumes one private IP from the dedicated endpoint subnet.
- The subnet CIDR must be sized appropriately (minimum `/27` or `/24` recommended).
- Network Security Groups (NSGs) must account for traffic directed to the distinct private IPs allocated to each service endpoint.
