# Operations and troubleshooting

| Symptom | Possible cause | Check |
|---|---|---|
| Public IP returned by DNS | Zone not linked or custom DNS not forwarding | VNet link, CNAME chain, conditional forwarder |
| Private IP but timeout | Routing, NSG, UDR or client firewall | TCP 443, effective routes, peering/VPN |
| HTTP 403 | Identity lacks data-plane permission | Entra token and Storage data role scope |
| Endpoint pending | Manual approval required | Connection state and target approval |
| Terraform deployment denied | RBAC, Azure Policy or quota | Activity Log and deployment error |

Useful commands:
```bash
az account show
az network private-endpoint list -g "<RG>" -o table
az network private-endpoint-connection list --id "<STORAGE_ACCOUNT_ID>"
az network private-dns record-set a list -g "<DNS_RG>" --zone-name "privatelink.blob.core.windows.net"
nslookup "<ACCOUNT>.blob.core.windows.net"
nc -vz "<ACCOUNT>.blob.core.windows.net" 443
```

Assign ownership for endpoint lifecycle, central DNS, cross-subscription approvals and hybrid DNS support.
