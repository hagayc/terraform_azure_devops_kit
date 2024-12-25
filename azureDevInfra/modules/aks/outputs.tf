output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
}

output "kubernetes_service_connection_name" {
  description = "The name of the Kubernetes service connection created in Azure DevOps"
  value       = azuredevops_serviceendpoint_kubernetes.k8s_service_connection.service_endpoint_name
}

output "kubernetes_service_connection_id" {
  description = "The ID of the Kubernetes service connection created in Azure DevOps"
  value       = azuredevops_serviceendpoint_kubernetes.k8s_service_connection.id
}
