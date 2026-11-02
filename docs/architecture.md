# Architecture

The root environment composes three modules: networking, storage and private-endpoint. The spoke VNet contains a dedicated endpoint subnet. Each enabled Storage subresource receives a distinct Private Endpoint. Azure provisions and manages the endpoint NIC automatically.

For enterprise hub-and-spoke, centrally own Private DNS zones in a connectivity subscription/resource group, link them to consuming VNets, and design hybrid DNS with Azure DNS Private Resolver or approved conditional forwarding. This sample keeps DNS resources local to the workload for portability.

A Private Endpoint targets one resource subresource. Blob, File, Queue and Table are separate endpoints. The client keeps using the standard Storage FQDN; DNS maps it through the Private Link CNAME chain to a private IP.
