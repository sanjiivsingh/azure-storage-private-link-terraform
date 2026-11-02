# Security and best practices

- Disable Storage public network access when private-only access is intended.
- Use Microsoft Entra ID data-plane RBAC and least privilege. Shared Key is disabled in this sample; verify all clients support Entra ID first.
- Enforce HTTPS and TLS 1.2; enable versioning and soft delete according to retention and cost needs.
- Use a dedicated endpoint subnet and plan IP capacity. Azure creates the endpoint NIC; do not create a separate NIC resource.
- Configure NSGs/UDRs only with the supported Private Endpoint network policy settings and test the actual traffic path.
- Centralize DNS zones in enterprise environments; avoid duplicate zones for the same namespace.
- Design custom/hybrid DNS forwarding before onboarding on-premises clients.
- Use a remote backend, state versioning/soft delete, Entra ID auth and restricted access.
- Never commit `.tfstate`, plan files, populated tfvars, credentials or secrets.
- Use OIDC/workload identity federation for CI and protect production applies with approvals.
- Add Azure Policy, diagnostic settings, Defender for Storage and alerting for production.
- Private Endpoint does not replace identity authorization, data-plane RBAC or application-level controls.
- This is a workload reference, not a complete enterprise landing zone.
