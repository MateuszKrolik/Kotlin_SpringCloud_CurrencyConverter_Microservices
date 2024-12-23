variable "db_hostname" {
  description = "Database hostname"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "config_map_name" {
  description = "Name of the Kubernetes ConfigMap containing configuration data"
  type        = string
  default     = "currency-config"
}