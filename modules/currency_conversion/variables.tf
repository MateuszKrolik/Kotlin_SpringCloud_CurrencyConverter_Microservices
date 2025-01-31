variable "config_map_name" {
  description = "Name of the Kubernetes ConfigMap containing configuration data"
  type        = string
}

variable "image_name" {
  type = string
}

variable "namespace" {
  description = "The namespace to deploy the resources"
  type        = string
}