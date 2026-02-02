# --- Resource Groups ---

output "connectivity_rg" {
  description = "Connectivity Resource Group name"
  value       = azurerm_resource_group.connectivity.name
}

output "service_rg" {
  description = "Service Resource Group name"
  value       = azurerm_resource_group.service.name
}

# --- Networking ---

output "dns_vnet_id" {
  description = "DNS VNet ID"
  value       = azurerm_virtual_network.dns.id
}

output "service_vnet_id" {
  description = "Service (spoke) VNet ID"
  value       = azurerm_virtual_network.service.id
}

output "service_subnet_id" {
  description = "Service subnet ID"
  value       = azurerm_subnet.service.id
}

# --- DNS Resolver ---

output "dns_resolver_id" {
  description = "Private DNS Resolver ID"
  value       = azurerm_private_dns_resolver.this.id
}

output "dns_resolver_inbound_ip" {
  description = "Private DNS Resolver inbound endpoint IP"
  value       = var.pdns_ip
}

output "dns_forwarding_ruleset_id" {
  description = "DNS Forwarding Ruleset ID"
  value       = azurerm_private_dns_resolver_dns_forwarding_ruleset.this.id
}

# --- DNS Zones ---

output "dns_zones" {
  description = "Private DNS zone names"
  value       = [for z in azurerm_private_dns_zone.this : z.name]
}

# --- Summary ---

output "deployed_assets_summary" {
  description = "Summary of deployed RMIT infrastructure assets"
  value = {
    resource_groups  = [azurerm_resource_group.connectivity.name, azurerm_resource_group.service.name]
    vnets            = [azurerm_virtual_network.dns.name, azurerm_virtual_network.service.name]
    subnets          = [azurerm_subnet.dns_inbound.name, azurerm_subnet.dns_outbound.name, azurerm_subnet.service.name]
    nsgs             = [azurerm_network_security_group.dns.name, azurerm_network_security_group.service.name]
    dns_resolver     = azurerm_private_dns_resolver.this.name
    dns_endpoints    = [azurerm_private_dns_resolver_inbound_endpoint.this.name, azurerm_private_dns_resolver_outbound_endpoint.this.name]
    dns_zones        = [for z in azurerm_private_dns_zone.this : z.name]
    network_watcher  = azurerm_network_watcher.this.name
  }
}
