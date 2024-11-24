variable "config_map_name" {
  description = "Name of the Kubernetes ConfigMap containing configuration data"
  type        = string
}

variable "db_secret_name" {
  description = "Name of the Kubernetes secret containing database credentials"
  type        = string
}