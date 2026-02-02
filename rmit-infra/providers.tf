terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription
  client_id       = var.client
  client_secret   = var.clientsecret
  tenant_id       = var.tenantazure
}
