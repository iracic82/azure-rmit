terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }
  }
}

# --- Resource Group ---

resource "azurerm_resource_group" "this" {
  name     = var.azure_resource_group
  location = var.azure_location

  tags = {
    Project     = "RMIT"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# --- Virtual Network ---

resource "azurerm_virtual_network" "this" {
  name                = var.azure_vnet_name
  address_space       = [var.azure_vnet_cidr]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = {
    Project     = "RMIT"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# --- Subnet ---

resource "azurerm_subnet" "this" {
  name                 = var.azure_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.azure_subnet_cidr]
}

# --- Public IP ---

resource "azurerm_public_ip" "this" {
  name                = "${var.azure_instance_name}-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Project     = "RMIT"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# --- Network Security Group ---

resource "azurerm_network_security_group" "this" {
  name                = "${var.azure_vnet_name}-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "SSH"
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
    name                       = "HTTP"
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
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ICMP"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Project     = "RMIT"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# --- Network Interface ---

resource "azurerm_network_interface" "this" {
  name                = "${var.azure_instance_name}-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.azure_private_ip
    public_ip_address_id          = azurerm_public_ip.this.id
  }

  tags = {
    Project     = "RMIT"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}

# --- NSG ↔ NIC Association ---

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# --- SSH Key Pair (TLS-generated) ---

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "pem" {
  content         = tls_private_key.this.private_key_pem
  filename        = "${path.root}/${var.azure_server_key_pair_name}.pem"
  file_permission = "0400"
}

# --- Linux Virtual Machine ---

resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.azure_instance_name
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = var.azure_vm_size
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.this.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.this.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(var.user_data)

  tags = {
    Project     = "RMIT"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}
