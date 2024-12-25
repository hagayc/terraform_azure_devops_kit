variable "location" {
  type     = string
  default  = "West Europe"
  nullable = false
  description = "Azure region for ALL azure DEV resources"
}

variable "azuredevops_org_url" {
  description = "azuredevops org url"
}

variable "azuredevops_pat" {
  description = "azuredevops pat"
}

variable "azure_subscription_id" {
  description = "azure subscription id"
}

variable "azure_subscription_name" {
  description = "azure default subscription name"
}

variable "azure_tenant_id" {
  description = "azure tenant id"
}

variable "dev_center_name" {
  description = "Azure DEV Center name"
}

variable "resource_group_name" {
  description = "Resource group name"
}

variable "project_name" {
  description = "Azure DevOps project name"
}

variable "organization_name" {
  description = "Azure DevOps Organization name"
}

variable "repo_name_app" {
  description = "Name of the Git repository for the Application"
}

variable "repo_name_iac" {
  description = "Name of the Git repository for Terraform IAC"
}

variable "acr_name" {
  description = "Azure Container Registry name"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
}

variable "node_count" {
  description = "Number of allocated AKS nodes"
}

variable "sql_server_name" {
  description = "Azure SQL Server name"
}

variable "database_name" {
  description = "Azure SQL Database name"
}

variable "username" {
  description = "Username for GIT connections"
}

variable "admin_login" {
  description = "Admin username for SQL Server"
}

variable "admin_password" {
  description = "Admin password for SQL Server"
}

