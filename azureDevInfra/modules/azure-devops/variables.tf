variable "resource_group_name" {}
variable "location" {}
variable "project_name" {}
variable "repo_name_app" {}
variable "repo_name_iac" {}
variable "dev_center_name" {}
variable "organization_name" {}
variable "username" {}
variable "azuredevops_pat" {
  description = "Azure DevOps Personal Access Token"
  sensitive   = true
}