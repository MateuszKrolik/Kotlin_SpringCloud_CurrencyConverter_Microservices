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

          env {
            name = "DB_HOSTNAME"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "DB_HOSTNAME"
              }
            }
          }

          env {
            name = "DB_PORT"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "DB_PORT"
              }
            }
          }

          env {
            name = "DB_NAME"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "DB_NAME"
              }
            }
          }

          env {
            name = "DB_USERNAME"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "DB_USERNAME"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "DB_PASSWORD"
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

resource "kubernetes_service" "currency_exchange" {
  metadata {
    name = "currency-exchange-new"
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