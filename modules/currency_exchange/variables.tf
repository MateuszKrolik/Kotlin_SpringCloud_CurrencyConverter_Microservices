variable "db_secret_name" {
  description = "Name of the Kubernetes secret containing database credentials"
  type        = string
}

variable "namespace" {
  description = "The namespace to deploy the resources"
  type        = string
}