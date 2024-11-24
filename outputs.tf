# Helm release status
output "helm_status" {
  description = "Status of the currency services Helm release"
  value       = helm_release.currency_services.status
}

# Database config
output "db_config_map" {
  description = "Name of the database config map"
  value       = kubernetes_config_map.currency_config.metadata[0].name
}

# Ingress endpoint
output "ingress_name" {
  description = "Name of the ingress resource"
  value       = kubernetes_ingress_v1.currency_ingress.metadata[0].name
}