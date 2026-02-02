# --- Networking ---

output "vnet_ids" {
  description = "VNet key → VNet ID"
  value       = { for k, v in module.azure_vnets_west_eu : k => v.vnet_id }
}

output "vnet_cidrs" {
  description = "VNet key → CIDR block"
  value       = { for k, v in var.West_EU_VNets : k => v.azure_vnet_cidr }
}

output "subnet_ids" {
  description = "VNet key → Subnet ID"
  value       = { for k, v in module.azure_vnets_west_eu : k => v.subnet_id }
}

# --- Compute ---

output "vm_public_ips" {
  description = "VNet key → VM Public IP"
  value       = { for k, v in module.azure_vnets_west_eu : k => v.public_ip }
}

output "vm_private_ips" {
  description = "VNet key → VM Private IP"
  value       = { for k, v in module.azure_vnets_west_eu : k => v.private_ip }
}

output "ssh_commands" {
  description = "VNet key → SSH command"
  value       = { for k, v in module.azure_vnets_west_eu : k => v.ssh_command }
}

# --- DNS ---

output "dns_zone_name" {
  description = "Azure Private DNS zone name"
  value       = azurerm_private_dns_zone.this.name
}

output "dns_records" {
  description = "DNS record key → FQDN"
  value       = { for k, v in azurerm_private_dns_a_record.this : k => v.fqdn }
}
