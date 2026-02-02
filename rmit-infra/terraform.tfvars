# ============================================================================
# RMIT POC — Infrastructure that mimics production asset types
#
# Naming convention: {type}-{mgmt_group}-{env_prefix}-{service}{region_prefix}
# Example: vnet-rmit-dev-connectivity-weu
# ============================================================================

management_group = "rmit"
environment      = "development"
teenus           = "connectivity"

location = {
  region        = "West Europe"
  region_prefix = "-weu"
}

# --- Tags ---
tag_spr           = "RMIT-POC"
tag_team          = "Infoblox-POC"
tag_contact       = "poc@rmit.ee"
tag_CreatedOnDate = "2025-01-01"

# --- DNS VNet (resolver inbound + outbound subnets) ---
dns_vnet_address_space = {
  inbound  = "10.200.1.0/24"
  outbound = "10.200.2.0/24"
}
pdns_ip = "10.200.1.10"

# --- Service (spoke) VNet ---
service_vnet_cidr   = "10.201.0.0/16"
service_subnet_cidr = "10.201.1.0/24"

# --- Private DNS Zones ---
dns_zones = [
  "rmit.internal",
  "emta.internal",
  "stat.internal",
]
