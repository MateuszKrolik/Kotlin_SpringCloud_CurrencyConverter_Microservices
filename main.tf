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
}

module "postgres" {
  source      = "./modules/postgres"
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}

module "currency_update" {
  source          = "./modules/currency_update"
  config_map_name = kubernetes_config_map.currency_config.metadata[0].name
  db_secret_name  = kubernetes_secret.db_secret.metadata[0].name
}

resource "kubernetes_config_map" "currency_config" {
  metadata {
    name = var.config_map_name
  }

  data = {
    CURRENCY_EXCHANGE_URI = "http://currency-exchange"
  }
}

resource "kubernetes_service" "currency_exchange" {
  metadata {
    name = "currency-exchange"
  }

  spec {
    selector = {
      app = "currency-exchange"
    }

    port {
      port        = 8000
      target_port = 8000
    }
  }
}

resource "kubernetes_service" "currency_conversion" {
  metadata {
    name = "currency-conversion"
  }

  spec {
    selector = {
      app = "currency-conversion"
    }

    port {
      port        = 8100
      target_port = 8100
    }
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
    tls {
      hosts      = ["currency-conversion.info"]
      secret_name = "currency-ingress-tls"
    }

    rule {
      host = "currency-conversion.info"
      http {
        path {
          path = "/currency-exchange"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.currency_exchange.metadata[0].name
              port {
                number = 8000
              }
            }
          }
        }
        path {
          path = "/currency-conversion-feign"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.currency_conversion.metadata[0].name
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
  values = [
    file("currency-services/values.yaml"),
    file("currency-services/values.secret.yaml")
  ]
}