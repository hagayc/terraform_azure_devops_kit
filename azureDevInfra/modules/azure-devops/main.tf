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

resource "azurerm_dev_center" "dev_center" {
  name                = var.dev_center_name
  resource_group_name = var.resource_group_name
  location            = var.location
  depends_on = [azurerm_resource_group.resource_group]
  # lifecycle {
  # prevent_destroy = true
  # }
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
  # depends_on = [azuredevops_project.project]
  # lifecycle {
  # prevent_destroy = true
  # }
}

resource "azuredevops_project" "project" {
  name       = var.project_name
  visibility = "private"
  # lifecycle {
  # prevent_destroy = true
  # }
}

resource "azuredevops_git_repository" "app_repo" {
  project_id = azuredevops_project.project.id
  name       = var.repo_name_app
  # lifecycle {
  #   prevent_destroy = true
  # }
  initialization {
    init_type = "Uninitialized"
  }
  depends_on = [azurerm_resource_group.resource_group]
}

resource "azuredevops_git_repository" "iac_repo" {
  project_id = azuredevops_project.project.id
  name       = var.repo_name_iac
  # lifecycle {
  #   prevent_destroy = true
  # }
  initialization {
    init_type = "Uninitialized"
  }
  depends_on = [azurerm_resource_group.resource_group]
}

# Create local file with Git credentials
resource "local_file" "git_credentials" {
  filename = "../${path.root}/git_credentials.txt"
  content  = <<-EOT
App Repository:
URL: ${azuredevops_git_repository.app_repo.remote_url}
Username: ${var.username}
Password: ${var.azuredevops_pat}

IAC Repository:
URL: ${azuredevops_git_repository.iac_repo.remote_url}
Username: ${var.username}
Password: ${var.azuredevops_pat}
EOT

  file_permission = "0600"  # Restricted file permissions for security
}
