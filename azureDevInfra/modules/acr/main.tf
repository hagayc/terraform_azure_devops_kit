terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
  admin_enabled       = true
  location            = var.location
  # lifecycle {
  # prevent_destroy = true
  # }
}

