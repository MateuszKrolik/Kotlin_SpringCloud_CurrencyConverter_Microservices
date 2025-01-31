resource "kubernetes_deployment" "currency_conversion" {
  metadata {
    name = "currency-conversion"
    labels = {
      app = "currency-conversion"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "currency-conversion"
      }
    }

    template {
      metadata {
        labels = {
          app = "currency-conversion"
        }
      }

      spec {
        security_context {
          run_as_user = 0
        }

        container {
          image = var.image_name
          name  = "currency-conversion"

          env {
            name = "CURRENCY_EXCHANGE_URI"
            value_from {
              config_map_key_ref {
                name = var.config_map_name
                key  = "CURRENCY_EXCHANGE_URI"
              }
            }
          }

          port {
            container_port = 8100
          }

          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
              port = 8100
            }
          }

          liveness_probe {
            http_get {
              path = "/actuator/health/liveness"
              port = 8100
            }
          }
        }
      }
    }
  }
}