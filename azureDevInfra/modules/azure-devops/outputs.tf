output "resource_group_name" {
  value = azurerm_resource_group.resource_group.name
}

output "project_name" {
  value = azuredevops_project.project.name
}

output "project_id" {
  value = azuredevops_project.project.id
}

output "app_url" {
  value = azuredevops_git_repository.app_repo.remote_url
}

output "iac_url" {
  value = azuredevops_git_repository.iac_repo.remote_url
}
