resource "kubernetes_deployment" "currency_exchange" {
  metadata {
    name = "currency-exchange"
    labels = {
      app = "currency-exchange"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "currency-exchange"
      }
    }

    template {
      metadata {
        labels = {
          app = "currency-exchange"
        }
      }

      spec {
        container {
          image = "mateuszkrolik/microservices-currency-exchange-service:0.0.1-SNAPSHOT"
          name  = "currency-exchange"

          dynamic "env" {
            for_each = {
              DB_HOSTNAME = "DB_HOSTNAME"
              DB_PORT     = "DB_PORT"
              DB_NAME     = "DB_NAME"
              DB_USERNAME = "DB_USERNAME"
              DB_PASSWORD = "DB_PASSWORD"
            }
            content {
              name = env.key
              value_from {
                secret_key_ref {
                  name = var.db_secret_name
                  key  = env.value
                }
              }
            }
          }

          port {
            container_port = 8000
          }

          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
              port = 8000
            }
            initial_delay_seconds = 150
            period_seconds = 5
            timeout_seconds = 5
            success_threshold = 1
            failure_threshold = 10
          }

          liveness_probe {
            http_get {
              path = "/actuator/health/liveness"
              port = 8000
            }
            initial_delay_seconds = 120
            period_seconds = 5
            timeout_seconds = 5
            success_threshold = 1
            failure_threshold = 10
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "1024Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}