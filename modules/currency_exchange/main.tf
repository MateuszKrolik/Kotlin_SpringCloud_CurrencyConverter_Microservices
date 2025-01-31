resource "kubernetes_config_map" "jmx_config" {
  metadata {
    name = "jmx-config"
  }

  data = {
    "config.yaml" = <<-EOT
      hostPort: localhost:9010
      lowercaseOutputName: true
      lowercaseOutputLabelNames: true
      rules:
      - pattern: ".*"
    EOT
  }
}

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
        security_context {
          run_as_user = 0
        }

        init_container {
          name  = "init-db-check"
          image = "postgres:17-alpine"

          command = ["sh", "-c", "until pg_isready -h postgres -p 5432; do echo waiting for database; sleep 2; done;"]

          env {
            name = "PGUSER"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "DB_USERNAME"
              }
            }
          }
          env {
            name = "PGPASSWORD"
            value_from {
              secret_key_ref {
                name = var.db_secret_name
                key  = "DB_PASSWORD"
              }
            }
          }
        }

        container {
          image = "mateuszkrolik/microservices-currency-exchange-service:0.0.1-SNAPSHOT"
          name  = "currency-exchange"

          env {
            name = "JAVA_TOOL_OPTIONS"
            value = "-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=9010 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
          }

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
          volume_mount {
            name = "jmx-socket"
            mount_path = "/tmp"
          }
        }
        container {
          name  = "prometheus-jmx-exporter"
          image = "bitnami/jmx-exporter:latest"

          port {
            container_port = 9404
            name = "metrics"
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

          args = [
            "9404",
            "/etc/jmx-exporter/config.yaml"
          ]

          volume_mount {
            name = "config-volume"
            mount_path = "/etc/jmx-exporter"
          }

          volume_mount {
            name = "jmx-socket"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "config-volume"
          config_map {
            name = "jmx-config"
          }
        }
        volume {
          name = "jmx-socket"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "currency_exchange" {
  metadata {
    name = "currency-exchange"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.currency_exchange.metadata[0].name
    }

    min_replicas = 1
    max_replicas = 5

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
  }
}