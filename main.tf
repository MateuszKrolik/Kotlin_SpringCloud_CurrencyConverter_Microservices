terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "currency_exchange" {
  source          = "./modules/currency_exchange"
  db_secret_name  = kubernetes_secret.db_secret.metadata[0].name
}

module "currency_conversion" {
  source          = "./modules/currency_conversion"
  config_map_name = kubernetes_config_map.currency_config.metadata[0].name
  image_name      = docker_image.currency_conversion.name
}

module "postgres" {
  source      = "./modules/postgres"
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

resource "kubernetes_config_map" "currency_config" {
  metadata {
    name = var.config_map_name
  }

  data = {
    CURRENCY_EXCHANGE_URI = "http://currency-exchange"
  }
}

resource "kubernetes_ingress_v1" "currency_ingress" {
  metadata {
    name = "currency-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "currency-services-exchange"
              port {
                number = 8000
              }
            }
          }
        }
        path {
          backend {
            service {
              name = "currency-services-conversion"
              port {
                number = 8100
              }
            }
          }
        }
      }
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "currency_services" {
  name       = "currency-services"
  repository = "https://charts.helm.sh/stable"
  chart      = "./currency-services"
  timeout    = 600 # 10 minutes

  set {
    name  = "currencyExchange.service.port"
    value = "8000"
  }

  set {
    name  = "currencyConversion.service.port"
    value = "8100"
  }

  set_sensitive {
    name  = "database.username"
    value = var.db_username
  }

  set_sensitive {
    name  = "database.password"
    value = var.db_password
  }

  values = [
    file("currency-services/values.yaml"),
  ]
}

resource "docker_image" "currency_conversion" {
  name         = "currency-conversion-service:local"
  build {
    context    = "${path.module}/currency-conversion-service"
    dockerfile = "Dockerfile"
  }
}