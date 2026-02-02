# --- Azure Private DNS Zone ---

resource "azurerm_private_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = module.azure_vnets_west_eu[keys(var.West_EU_VNets)[0]].resource_group_name

  tags = {
    Project     = "RMIT"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# --- VNet Links (associate each VNet with the Private DNS zone) ---

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.West_EU_VNets

  name                  = "${each.value.azure_vnet_name}-dns-link"
  resource_group_name   = module.azure_vnets_west_eu[keys(var.West_EU_VNets)[0]].resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = module.azure_vnets_west_eu[each.key].vnet_id
  registration_enabled  = false

  tags = {
    Project     = "RMIT"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# --- DNS A Records (derived from VNet app_fqdn via for_each) ---

locals {
  dns_records = {
    for key, vnet in var.West_EU_VNets : key => {
      # Extract the hostname from the FQDN (e.g. "app1" from "app1.rmit.internal")
      name       = split(".", vnet.app_fqdn)[0]
      private_ip = vnet.azure_private_ip
    }
  }
}

resource "azurerm_private_dns_a_record" "this" {
  for_each = local.dns_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = module.azure_vnets_west_eu[keys(var.West_EU_VNets)[0]].resource_group_name
  ttl                 = 300
  records             = [each.value.private_ip]

  tags = {
    Project     = "RMIT"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}
