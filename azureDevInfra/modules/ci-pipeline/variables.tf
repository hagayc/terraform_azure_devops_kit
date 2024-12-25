variable "project_name" {}
variable "repo_name_app" {}

variable "password_end_date" {
  description = "End date for the service principal password"
  default     = "2099-12-31T23:59:59Z"
}

variable "scope" {
  description = "The scope at which the role assignment applies"
}

variable "role_name" {
  description = "The name of the role to assign to the service principal"
}

variable "sp_name" {
  description = "The name of the service principal"
  type        = string
}

variable "project_id" {
  description = "Azure DevOps project ID"
  type        = string
}

variable "acr_name" {
  description = "Azure Container Registry name without .azurecr.io"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing ACR and AKS"
  type        = string
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubernetes_service_connection_id" {
  description = "The ID of the Kubernetes service connection from AKS module"
  type        = string
}

variable "environment_id" {
  description = "The ID of the Azure DevOps environment"
  type        = string
}
