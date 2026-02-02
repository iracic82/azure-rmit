variable "azure_resource_group" {
  description = "Name for the Azure Resource Group"
  type        = string
}

variable "azure_location" {
  description = "Azure region for resource deployment"
  type        = string
}

variable "azure_vnet_name" {
  description = "Name tag for the Virtual Network"
  type        = string
}

variable "azure_vnet_cidr" {
  description = "CIDR block for the Virtual Network"
  type        = string

  validation {
    condition     = can(cidrhost(var.azure_vnet_cidr, 0))
    error_message = "azure_vnet_cidr must be a valid CIDR block (e.g. 10.10.0.0/16)."
  }
}

variable "azure_subnet_name" {
  description = "Name tag for the Subnet"
  type        = string
}

variable "azure_subnet_cidr" {
  description = "CIDR block for the Subnet"
  type        = string

  validation {
    condition     = can(cidrhost(var.azure_subnet_cidr, 0))
    error_message = "azure_subnet_cidr must be a valid CIDR block (e.g. 10.10.1.0/24)."
  }
}

variable "azure_instance_name" {
  description = "Name tag for the Virtual Machine"
  type        = string
}

variable "azure_server_key_pair_name" {
  description = "Name for the SSH key pair file"
  type        = string
}

variable "azure_private_ip" {
  description = "Static private IP for the VM NIC"
  type        = string

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.azure_private_ip))
    error_message = "azure_private_ip must be a valid IPv4 address (e.g. 10.10.1.10)."
  }
}

variable "azure_vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "user_data" {
  description = "User data script for VM bootstrap (cloud-init)"
  type        = string
  default     = ""
}
