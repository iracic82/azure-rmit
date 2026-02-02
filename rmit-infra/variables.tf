# --- Azure Authentication ---

variable "subscription" {
  description = "Azure Subscription ID"
  type        = string
}

variable "client" {
  description = "Azure Service Principal (SPN) Client ID"
  type        = string
}

variable "clientsecret" {
  description = "Azure Service Principal (SPN) Client Secret"
  type        = string
  sensitive   = true
}

variable "tenantazure" {
  description = "Azure Tenant ID"
  type        = string
}

# --- RMIT Naming Convention ---

variable "management_group" {
  description = "Management group (rmit, emta, rab, ram, rtk, stat)"
  type        = string
  default     = "rmit"
}

variable "environment" {
  description = "Environment: production / test / development"
  type        = string
  default     = "development"
}

variable "environment_prefix_map" {
  description = "Maps environment name to prefix"
  type        = map(string)
  default = {
    production  = "prod"
    test        = "test"
    development = "dev"
  }
}

variable "teenus" {
  description = "Service name (teenus)"
  type        = string
  default     = "connectivity"
}

variable "location" {
  description = "Azure region and prefix"
  type = object({
    region        = string
    region_prefix = string
  })
  default = {
    region        = "West Europe"
    region_prefix = "-weu"
  }
}

# --- Tags ---

variable "tag_spr" {
  description = "TAG - SPR"
  type        = string
  default     = "RMIT-POC"
}

variable "tag_team" {
  description = "TAG - Team"
  type        = string
  default     = "Infoblox-POC"
}

variable "tag_contact" {
  description = "TAG - Contact"
  type        = string
  default     = "poc@rmit.ee"
}

variable "tag_CreatedOnDate" {
  description = "TAG - CreatedOnDate YYYY-MM-DD"
  type        = string
  default     = "2025-01-01"
}

# --- Networking ---

variable "dns_vnet_address_space" {
  description = "Address space for DNS resolver VNet (inbound + outbound subnets)"
  type = object({
    inbound  = string
    outbound = string
  })
  default = {
    inbound  = "10.200.1.0/24"
    outbound = "10.200.2.0/24"
  }
}

variable "pdns_ip" {
  description = "Private DNS resolver inbound endpoint IP"
  type        = string
  default     = "10.200.1.10"
}

variable "service_vnet_cidr" {
  description = "Service (spoke) VNet CIDR"
  type        = string
  default     = "10.201.0.0/16"
}

variable "service_subnet_cidr" {
  description = "Service (spoke) subnet CIDR"
  type        = string
  default     = "10.201.1.0/24"
}

variable "service_vm_size" {
  description = "Azure VM size for the spoke VM"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "service_vm_private_ip" {
  description = "Static private IP for the spoke VM"
  type        = string
  default     = "10.201.1.10"
}

variable "dns_zones" {
  description = "Private DNS zones to create"
  type        = list(string)
  default = [
    "rmit.internal",
    "emta.internal",
    "stat.internal",
  ]
}
