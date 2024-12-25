terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# Add data source for current subscription
data "azurerm_subscription" "current" {}

# Create k8s cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = "israelcentral"
  resource_group_name = var.resource_group
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Create Kubernetes service connection
resource "azuredevops_serviceendpoint_kubernetes" "k8s_service_connection" {
  project_id            = var.project_id
  service_endpoint_name = "AKS-Service-Connection"
  apiserver_url        = azurerm_kubernetes_cluster.aks.kube_config[0].host
  authorization_type   = "AzureSubscription"

  azure_subscription {
    subscription_id   = trimprefix(data.azurerm_subscription.current.id, "/subscriptions/")
    subscription_name = data.azurerm_subscription.current.display_name
    tenant_id        = data.azurerm_subscription.current.tenant_id
    resourcegroup_id = var.resource_group
    namespace        = "default"
    cluster_name     = var.cluster_name
  }
}

# Add authorization for the Kubernetes service connection
resource "azuredevops_pipeline_authorization" "k8s_service_connection_auth" {
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_kubernetes.k8s_service_connection.id
  type        = "endpoint"
}

# Create the environment
resource "azuredevops_environment" "aks_env" {
  project_id = var.project_id
  name       = "azure-dev-aks-environment"
}

# Link the environment to the Kubernetes cluster
resource "azuredevops_environment_resource_kubernetes" "aks_env_resource" {
  project_id          = var.project_id
  environment_id      = azuredevops_environment.aks_env.id
  name               = "aks-resource"
  service_endpoint_id = azuredevops_serviceendpoint_kubernetes.k8s_service_connection.id
  namespace          = "default"
  cluster_name       = var.cluster_name
}

# Add an output for the environment ID
output "environment_id" {
  description = "The ID of the AKS environment"
  value       = azuredevops_environment.aks_env.id
}

resource "azuredevops_pipeline_authorization" "k8s_connection_auth" {
  project_id  = var.project_id
  resource_id = azuredevops_serviceendpoint_kubernetes.k8s_service_connection.id
  type        = "endpoint"
}

# Add this data source to get ACR details
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group
}

# Add this role assignment to allow AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                           = data.azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}


