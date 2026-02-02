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

# --- VNet Definitions ---

variable "West_EU_VNets" {
  description = "Map of VNet configurations for West Europe region"
  type = map(object({
    azure_resource_group       = string
    azure_location             = string
    azure_vnet_name            = string
    azure_subnet_name          = string
    azure_instance_name        = string
    azure_server_key_pair_name = string
    azure_private_ip           = string
    azure_vm_size              = string
    azure_vnet_cidr            = string
    azure_subnet_cidr          = string
    app_fqdn                   = string
  }))
  default = {}
}

# --- DNS ---

variable "dns_zone_name" {
  description = "Azure Private DNS zone name"
  type        = string
  default     = "rmit.internal"
}

# --- Participant ---

variable "participant_id" {
  description = "Unique participant ID (from INSTRUQT_PARTICIPANT_ID) — used to isolate resources per user"
  type        = string
  default     = "local"
}
