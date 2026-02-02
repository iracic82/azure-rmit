# --- DNS ---

dns_zone_name = "rmit.internal"

# --- VNet Definitions ---
# Add/remove entries to scale. Each entry creates:
#   RG → VNet → Subnet → NSG → NIC → PIP → VM → SSH Key
#   + Private DNS A record from app_fqdn → azure_private_ip

West_EU_VNets = {
  VNet1 = {
    azure_resource_group       = "RMIT-RG1"
    azure_location             = "West Europe"
    azure_vnet_name            = "RMIT-VNet1"
    azure_subnet_name          = "RMIT-VNet1-Subnet"
    azure_instance_name        = "RMIT-Web1"
    azure_server_key_pair_name = "RMIT_WestEU_1"
    azure_private_ip           = "10.10.1.10"
    azure_vm_size              = "Standard_DS2_v2"
    azure_vnet_cidr            = "10.10.0.0/16"
    azure_subnet_cidr          = "10.10.1.0/24"
    app_fqdn                   = "app1.rmit.internal"
  }
  VNet2 = {
    azure_resource_group       = "RMIT-RG2"
    azure_location             = "West Europe"
    azure_vnet_name            = "RMIT-VNet2"
    azure_subnet_name          = "RMIT-VNet2-Subnet"
    azure_instance_name        = "RMIT-Web2"
    azure_server_key_pair_name = "RMIT_WestEU_2"
    azure_private_ip           = "10.20.1.10"
    azure_vm_size              = "Standard_DS2_v2"
    azure_vnet_cidr            = "10.20.0.0/16"
    azure_subnet_cidr          = "10.20.1.0/24"
    app_fqdn                   = "app2.rmit.internal"
  }
}
