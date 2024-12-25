output "login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_username" {
  value = {
    username = azurerm_container_registry.acr.admin_username
  }
}

output "acr_password" {
  value = {
    password = azurerm_container_registry.acr.admin_password
  }
}
