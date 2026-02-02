# --- Resource Group ---

output "resource_group_name" {
  description = "Resource Group name"
  value       = azurerm_resource_group.this.name
}

# --- Networking ---

output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_cidr" {
  description = "Virtual Network CIDR block"
  value       = azurerm_virtual_network.this.address_space[0]
}

output "subnet_id" {
  description = "Subnet ID"
  value       = azurerm_subnet.this.id
}

output "nsg_id" {
  description = "Network Security Group ID"
  value       = azurerm_network_security_group.this.id
}

# --- Compute ---

output "vm_id" {
  description = "Virtual Machine ID"
  value       = azurerm_linux_virtual_machine.this.id
}

output "public_ip" {
  description = "VM Public IP"
  value       = azurerm_public_ip.this.ip_address
}

output "private_ip" {
  description = "VM Private IP"
  value       = var.azure_private_ip
}

output "key_pair_name" {
  description = "SSH key pair name"
  value       = var.azure_server_key_pair_name
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -o StrictHostKeyChecking=no -i ${var.azure_server_key_pair_name}.pem azureuser@${azurerm_public_ip.this.ip_address}"
}
