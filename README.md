# Azure RMIT — Infoblox POC Playground

Companion repository for the **RMIT POC Playground** Instruqt lab track. Contains Terraform infrastructure and Infoblox Cloud Discovery scripts for Azure.

## Structure

```
azure-rmit/
├── terraform/              # Main lab infrastructure
│   ├── main.tf             # 2 VNets via for_each module calls
│   ├── variables.tf        # VNet map + Azure auth vars
│   ├── terraform.tfvars    # RMIT-VNet1, RMIT-VNet2 defaults
│   ├── providers.tf        # azurerm provider (West Europe)
│   ├── outputs.tf          # VNet IDs, VM IPs, SSH commands
│   ├── dns.tf              # Azure Private DNS (rmit.internal)
│   ├── modules/
│   │   └── azure-vnet/     # Reusable module: RG, VNet, Subnet, NSG, NIC, PIP, VM
│   ├── templates/
│   │   └── user-data.sh    # Docker + nginx welcome page
│   └── scripts/
│       ├── deploy_azure_discovery.py   # Azure Cloud Discovery
│       ├── purge_discovery_jobs.py     # Cleanup all providers
│       ├── azure_payload_template.json # Azure discovery payload
│       ├── create_sandbox.py           # CSP sandbox management
│       ├── create_user.py
│       ├── delete_sandbox.py
│       ├── delete_user.py
│       ├── deploy_api_key.py
│       └── sandbox_api.py
├── rmit-infra/             # RMIT-style infrastructure (optional step)
│   ├── main.tf             # Mirrors RMIT production asset types
│   ├── variables.tf        # RMIT naming convention vars
│   ├── terraform.tfvars    # dev environment defaults
│   ├── providers.tf        # azurerm provider
│   └── outputs.tf          # Asset summary
└── web/
    └── index.html          # Standalone welcome page
```

## Main Lab Infrastructure (`terraform/`)

Deploys 2 Virtual Networks with Linux VMs running Docker/nginx:

| VNet | CIDR | VM | Private IP | DNS Record |
|------|------|----|------------|------------|
| RMIT-VNet1 | 10.10.0.0/16 | RMIT-Web1 | 10.10.1.10 | app1.rmit.internal |
| RMIT-VNet2 | 10.20.0.0/16 | RMIT-Web2 | 10.20.1.10 | app2.rmit.internal |

## RMIT-Style Infrastructure (`rmit-infra/`)

Optional deployment that mirrors RMIT production asset types using their naming convention (`{type}-{mgmt_group}-{env}-{service}{region}`), without heavy connectivity pieces (vWAN, VPN, Palo Alto):

- Connectivity + Service Resource Groups
- DNS VNet with inbound/outbound subnets
- Private DNS Resolver with endpoints
- DNS Forwarding Ruleset
- Private DNS Zones (rmit.internal, emta.internal, stat.internal)
- Service (spoke) VNet with VM running Docker/nginx
- NSGs, Network Watcher

## Usage

Deployed automatically by the Instruqt lab. For local testing:

```bash
cd terraform/
export TF_VAR_subscription="..."
export TF_VAR_client="..."
export TF_VAR_clientsecret="..."
export TF_VAR_tenantazure="..."
terraform init && terraform apply -auto-approve
```
