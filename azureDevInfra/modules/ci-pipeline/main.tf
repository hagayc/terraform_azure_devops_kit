terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

# Create Azure AD Application
resource "azuread_application" "sp_app" {
  display_name = var.sp_name
}

# Create Service Principal
resource "azuread_service_principal" "sp" {
  client_id = azuread_application.sp_app.client_id
}

# Create Service Principal password
resource "azuread_service_principal_password" "sp_password" {
  service_principal_id = azuread_service_principal.sp.id
  end_date            = timeadd(timestamp(), "8760h")  # 1 year from now
}

# Get current Azure subscription details
data "azurerm_subscription" "current" {}

# Data sources for existing ACR and AKS
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

# Azure Service Connection for general Azure resources (including AKS)
resource "azuredevops_serviceendpoint_azurerm" "azure_service_connection" {
  project_id                = var.project_id
  service_endpoint_name     = "Azure-Service-Connection"
  description              = "Service connection for Azure resources"
  
  credentials {
    serviceprincipalid  = azuread_application.sp_app.client_id
    serviceprincipalkey = azuread_service_principal_password.sp_password.value
  }
  
  azurerm_spn_tenantid      = data.azurerm_subscription.current.tenant_id
  azurerm_subscription_id   = data.azurerm_subscription.current.subscription_id
  azurerm_subscription_name = data.azurerm_subscription.current.display_name
}

# ACR Service Connection
resource "azuredevops_serviceendpoint_dockerregistry" "acr_service_connection" {
  project_id            = var.project_id
  service_endpoint_name = "ACR-Service-Connection"
  description          = "Service connection for Azure Container Registry"
  
  docker_registry      = "${var.acr_name}.azurecr.io"
  docker_username      = azuread_application.sp_app.client_id
  docker_password      = azuread_service_principal_password.sp_password.value
  registry_type        = "Others"
}

# Grant pipeline permissions to use the service connections
resource "azuredevops_pipeline_authorization" "azure_service_connection_auth" {
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_azurerm.azure_service_connection.id
  type = "endpoint"
}

resource "azuredevops_pipeline_authorization" "acr_service_connection_auth" {
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_dockerregistry.acr_service_connection.id
  type = "endpoint"
}

# Assign AcrPush role for ACR
resource "azurerm_role_assignment" "sp_acr_push" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.sp.object_id
}

# Assign Azure Kubernetes Service Cluster User Role
resource "azurerm_role_assignment" "sp_aks_user" {
  scope                = data.azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.sp.object_id
}

# Update the environment authorization to use the passed environment ID
resource "azuredevops_pipeline_authorization" "environment_auth" {
  project_id  = var.project_id
  resource_id = var.environment_id
  pipeline_id = azuredevops_build_definition.ci_pipeline.id
  type        = "environment"
}

# Your existing Kubernetes service connection authorization
resource "azuredevops_pipeline_authorization" "k8s_service_connection_auth" {
  project_id  = var.project_id
  resource_id = var.kubernetes_service_connection_id
  pipeline_id = azuredevops_build_definition.ci_pipeline.id
  type        = "endpoint"
}


# Azure DevOps Build Definition with Service Connections
resource "azuredevops_build_definition" "ci_pipeline" {
  project_id = var.project_id
  name       = "buildazureApp"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_id   = var.repo_name_app
    repo_type = "TfsGit"
    yml_path  = "ci-pipeline.yml"
  }

  variable_groups = [
    azuredevops_variable_group.pipeline_vars.id
  ]
}


resource "azuredevops_pipeline_authorization" "azure_connection_auth" {
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_azurerm.azure_service_connection.id
  type        = "endpoint"
}

resource "azuredevops_pipeline_authorization" "acr_connection_auth" {
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_dockerregistry.acr_service_connection.id
  type        = "endpoint"
}

# Add the Kubernetes service connection name to the variable group
resource "azuredevops_variable_group" "pipeline_vars" {
  project_id   = var.project_id
  name         = "Pipeline Variables"
  description  = "Pipeline variables for service connections"
  allow_access = true

  variable {
    name  = "AZURE_SERVICE_CONNECTION_NAME"
    value = azuredevops_serviceendpoint_azurerm.azure_service_connection.service_endpoint_name
  }

  variable {
    name  = "ACR_SERVICE_CONNECTION_NAME"
    value = azuredevops_serviceendpoint_dockerregistry.acr_service_connection.service_endpoint_name
  }

  variable {
  name  = "KUBERNETES_SERVICE_CONNECTION_NAME"
  value = var.kubernetes_service_connection_id
 }
}
