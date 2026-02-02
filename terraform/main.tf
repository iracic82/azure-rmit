# --- Default user data from template ---

locals {
  default_user_data = file("${path.module}/templates/user-data.sh")
}

# --- Deploy VNet + VM via for_each ---

module "azure_vnets_west_eu" {
  source   = "./modules/azure-vnet"
  for_each = var.West_EU_VNets

  azure_resource_group       = each.value.azure_resource_group
  azure_location             = each.value.azure_location
  azure_vnet_name            = each.value.azure_vnet_name
  azure_vnet_cidr            = each.value.azure_vnet_cidr
  azure_subnet_name          = each.value.azure_subnet_name
  azure_subnet_cidr          = each.value.azure_subnet_cidr
  azure_instance_name        = each.value.azure_instance_name
  azure_server_key_pair_name = each.value.azure_server_key_pair_name
  azure_private_ip           = each.value.azure_private_ip
  azure_vm_size              = each.value.azure_vm_size
  user_data                  = local.default_user_data
}
