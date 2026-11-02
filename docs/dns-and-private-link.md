# DNS and Private Link

- **Private Link:** private connectivity from a VNet to an Azure service.
- **Private Endpoint:** a NIC with a private IP in your VNet, mapped to one target resource/subresource.
- **Private DNS zone:** hosts private DNS records for the service namespace.
- **VNet link:** makes the private zone resolvable through the linked VNet DNS path.
- **Private DNS zone group:** associates an endpoint with DNS zones and lets Azure manage endpoint records.
- **Private service connection:** identifies target resource ID and subresource name.

Storage zones:
| Subresource | Zone |
|---|---|
| Blob | `privatelink.blob.core.windows.net` |
| File | `privatelink.file.core.windows.net` |
| Queue | `privatelink.queue.core.windows.net` |
| Table | `privatelink.table.core.windows.net` |

Use `for_each` on the endpoint resource because each subresource is a distinct resource with independent lifecycle. A dynamic block only repeats nested blocks inside one resource; it cannot create multiple top-level Private Endpoints. Each endpoint has one `private_service_connection` block here, so no dynamic block is needed.

If the VNet uses custom DNS, configure conditional forwarding or Azure DNS Private Resolver. A VNet link by itself does not make custom DNS servers forward queries to Azure DNS.
