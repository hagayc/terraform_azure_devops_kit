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

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

provider "azuredevops" {
  org_service_url       = var.azuredevops_org_url
  personal_access_token = var.azuredevops_pat
}

module "azure_devops" {
  source              = "./modules/azure-devops"
  resource_group_name = var.resource_group_name
  location            = var.location
  project_name        = var.project_name
  repo_name_app       = var.repo_name_app
  repo_name_iac       = var.repo_name_iac
  dev_center_name     = var.dev_center_name
  username            = var.username
  organization_name   = var.organization_name
  azuredevops_pat     = var.azuredevops_pat
}

module "acr" {
  source = "./modules/acr"
  acr_name            = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  depends_on = [module.azure_devops]
}

module "aks" {
  source           = "./modules/aks"
  cluster_name     = var.aks_cluster_name
  location         = var.location
  resource_group   = var.resource_group_name
  project_id       = module.azure_devops.project_id
  acr_name         = var.acr_name
  dns_prefix       = var.dns_prefix
  node_count       = var.node_count
  depends_on = [module.acr]
}

module "ci_pipeline" {
  source     = "./modules/ci-pipeline"
  project_name = var.project_name
  repo_name_app    = var.repo_name_app
  acr_name         = var.acr_name
  aks_cluster_name = var.aks_cluster_name
  resource_group_name = var.resource_group_name
  project_id = module.azure_devops.project_id
  sp_name   = "my-service-principal"               # Provide the service principal name
  scope     = "/subscriptions/Azure subscription 1" # Replace with the actual scope
  role_name = "Contributor"                        # Assign the desired role
  kubernetes_service_connection_id = module.aks.kubernetes_service_connection_id
  environment_id = module.aks.environment_id
  depends_on = [module.aks]
}

