# ============================================================================
# RMIT Infrastructure — Simplified POC
#
# Mirrors the RMIT production naming convention and asset types without
# the heavy connectivity pieces (vWAN, VPN GW, Palo Alto NGFW).
#
# Assets deployed here are the same types that Infoblox Cloud Discovery
# will inventory, so the discovered resources look familiar.
# ============================================================================

locals {
  env_prefix = var.environment_prefix_map[var.environment]
  tags = {
    SPR           = var.tag_spr
    Team          = var.tag_team
    Contact       = var.tag_contact
    Environment   = var.environment
    CreatedOnDate = var.tag_CreatedOnDate
    ManagedBy     = "Terraform"
  }
}

# ─── Connectivity Resource Group ─────────────────────────────────────────────

resource "azurerm_resource_group" "connectivity" {
  name     = "rg-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}"
  location = var.location.region
  tags     = local.tags
}

# ─── Network Watcher ─────────────────────────────────────────────────────────

resource "azurerm_network_watcher" "this" {
  name                = "nw-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  tags                = local.tags
}

# ─── DNS VNet (inbound + outbound subnets) ───────────────────────────────────

resource "azurerm_virtual_network" "dns" {
  name                = "vnet-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}-dns"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name
  address_space       = [var.dns_vnet_address_space.inbound, var.dns_vnet_address_space.outbound]
  tags                = local.tags
}

# ─── NSG for DNS subnets ─────────────────────────────────────────────────────

resource "azurerm_network_security_group" "dns" {
  name                = "nsg-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}"
  location            = azurerm_resource_group.connectivity.location
  resource_group_name = azurerm_resource_group.connectivity.name

  security_rule {
    name                       = "nsgsr-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}-001"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "nsgsr-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}-002"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

# ─── DNS Inbound Subnet ─────────────────────────────────────────────────────

resource "azurerm_subnet" "dns_inbound" {
  name                 = "snet-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}-inbound"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.dns.name
  address_prefixes     = [var.dns_vnet_address_space.inbound]

  delegation {
    name = "dnsresolverdelegation-inbound"
    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "dns_inbound" {
  subnet_id                 = azurerm_subnet.dns_inbound.id
  network_security_group_id = azurerm_network_security_group.dns.id
}

# ─── DNS Outbound Subnet ────────────────────────────────────────────────────

resource "azurerm_subnet" "dns_outbound" {
  name                 = "snet-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}-outbound"
  resource_group_name  = azurerm_resource_group.connectivity.name
  virtual_network_name = azurerm_virtual_network.dns.name
  address_prefixes     = [var.dns_vnet_address_space.outbound]

  delegation {
    name = "dnsresolverdelegation-outbound"
    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "dns_outbound" {
  subnet_id                 = azurerm_subnet.dns_outbound.id
  network_security_group_id = azurerm_network_security_group.dns.id
}

# ─── Private DNS Resolver ────────────────────────────────────────────────────

resource "azurerm_private_dns_resolver" "this" {
  name                = "pdns-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}"
  resource_group_name = azurerm_resource_group.connectivity.name
  location            = azurerm_resource_group.connectivity.location
  virtual_network_id  = azurerm_virtual_network.dns.id
  tags                = local.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  name                    = "pdnsrep-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}-in"
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = azurerm_resource_group.connectivity.location

  ip_configurations {
    private_ip_allocation_method = "Static"
    private_ip_address           = var.pdns_ip
    subnet_id                    = azurerm_subnet.dns_inbound.id
  }

  tags = local.tags
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "this" {
  name                    = "pdnsrep-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}-out"
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = azurerm_resource_group.connectivity.location
  subnet_id               = azurerm_subnet.dns_outbound.id
  tags                    = local.tags
}

# ─── DNS Forwarding Ruleset ──────────────────────────────────────────────────

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "this" {
  name                                       = "pdnsrs-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}"
  resource_group_name                        = azurerm_resource_group.connectivity.name
  location                                   = azurerm_resource_group.connectivity.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.this.id]
  tags                                       = local.tags
}

# ─── Private DNS Zones ───────────────────────────────────────────────────────

resource "azurerm_private_dns_zone" "this" {
  for_each = toset(var.dns_zones)

  name                = each.value
  resource_group_name = azurerm_resource_group.connectivity.name
  tags                = local.tags
}

# Link DNS zones to the DNS resolver VNet
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zones" {
  for_each = azurerm_private_dns_zone.this

  name                  = "pdnszlnk-${var.management_group}-${local.env_prefix}-${var.teenus}${var.location.region_prefix}-${replace(each.value.name, ".", "-")}"
  resource_group_name   = azurerm_resource_group.connectivity.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.dns.id
  registration_enabled  = false
  tags                  = local.tags
}

# ─── Service (Spoke) Resource Group ──────────────────────────────────────────

resource "azurerm_resource_group" "service" {
  name     = "rg-${var.management_group}-${local.env_prefix}-${var.teenus}-networkcp"
  location = var.location.region
  tags     = local.tags
}

# ─── Service VNet ────────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "service" {
  name                = "vnet-${var.management_group}-${local.env_prefix}-${var.teenus}"
  location            = azurerm_resource_group.service.location
  resource_group_name = azurerm_resource_group.service.name
  address_space       = [var.service_vnet_cidr]
  dns_servers         = [var.pdns_ip]
  tags                = local.tags
}

resource "azurerm_subnet" "service" {
  name                 = "snet-${var.management_group}-${local.env_prefix}-${var.teenus}-default"
  resource_group_name  = azurerm_resource_group.service.name
  virtual_network_name = azurerm_virtual_network.service.name
  address_prefixes     = [var.service_subnet_cidr]
}

# ─── Service NSG ─────────────────────────────────────────────────────────────

resource "azurerm_network_security_group" "service" {
  name                = "nsg-${var.management_group}-${local.env_prefix}-${var.teenus}-service"
  location            = azurerm_resource_group.service.location
  resource_group_name = azurerm_resource_group.service.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "service" {
  subnet_id                 = azurerm_subnet.service.id
  network_security_group_id = azurerm_network_security_group.service.id
}

# ─── Link Service VNet to DNS Zones (auto-registration on first zone) ────────

resource "azurerm_private_dns_zone_virtual_network_link" "service" {
  for_each = azurerm_private_dns_zone.this

  name                  = "pdnszlnk-${var.management_group}-${local.env_prefix}-${var.teenus}-svc-${replace(each.value.name, ".", "-")}"
  resource_group_name   = azurerm_resource_group.connectivity.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.service.id
  registration_enabled  = each.value.name == var.dns_zones[0] ? true : false
  tags                  = local.tags
}

# ─── Link Service VNet to DNS Forwarding Ruleset ────────────────────────────

resource "azurerm_private_dns_resolver_virtual_network_link" "service" {
  name                      = "pdnsrlnk-${var.management_group}-${local.env_prefix}-${var.teenus}"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this.id
  virtual_network_id        = azurerm_virtual_network.service.id
}
