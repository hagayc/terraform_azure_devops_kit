output "client_id" {
  value     = azuread_application.sp_app.client_id
  sensitive = true
}

output "client_secret" {
  value     = azuread_service_principal_password.sp_password
  sensitive = true
}

output "object_id" {
  value     = azuread_service_principal.sp.object_id
  sensitive = true
}