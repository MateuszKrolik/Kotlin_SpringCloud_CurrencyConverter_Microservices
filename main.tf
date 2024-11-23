provider "kubernetes" {
  config_path = "~/.kube/config"
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
        container {
          image = "mateuszkrolik/microservices-currency-exchange-service:0.0.1-SNAPSHOT"
          name  = "currency-exchange"

          env {
            name = "DB_HOSTNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secret.metadata[0].name
                key  = "DB_HOSTNAME"
              }
            }
          }

          env {
            name = "DB_PORT"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secret.metadata[0].name
                key  = "DB_PORT"
              }
            }
          }

          env {
            name = "DB_NAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secret.metadata[0].name
                key  = "DB_NAME"
              }
            }
          }

          env {
            name = "DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secret.metadata[0].name
                key  = "DB_USERNAME"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secret.metadata[0].name
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

resource "kubernetes_config_map" "currency_config" {
  metadata {
    name = "currency-config"
  }

  data = {
    CURRENCY_EXCHANGE_URI = "http://currency-exchange"
  }
}

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
          image = "mateuszkrolik/microservices-currency-conversion-service:0.0.1-SNAPSHOT"
          name  = "currency-conversion"

          env {
            name = "CURRENCY_EXCHANGE_URI"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.currency_config.metadata[0].name
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

resource "kubernetes_persistent_volume" "postgres_pv" {
  metadata {
    name = "postgres-pv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      host_path {
        path = "/mnt/data/postgres"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name = "postgres-pvc"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:17-alpine"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_DB"
            value = var.db_name
          }

          env {
            name  = "POSTGRES_USER"
            value = var.db_username
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = var.db_password
          }

          volume_mount {
            name      = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = "postgres-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    cluster_ip = "None"  # Headless service for StatefulSet
  }
}

resource "kubernetes_cron_job_v1" "currency_update" {
  metadata {
    name = "currency-update"
  }

  spec {
    schedule = "0 0 * * *"  # Runs every day at midnight
    job_template {
      metadata {
        name = "currency-update-job"
      }
      spec {
        template {
          metadata {
            name = "currency-update-template"
          }
          spec {
            container {
              name  = "currency-update"
              image = "mateuszkrolik/microservices-currency-update-job:0.0.1-SNAPSHOT"

              env {
                name = "CURRENCY_EXCHANGE_URI"
                value_from {
                  config_map_key_ref {
                    name = kubernetes_config_map.currency_config.metadata[0].name
                    key  = "CURRENCY_EXCHANGE_URI"
                  }
                }
              }

              env {
                name = "DB_HOSTNAME"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.db_secret.metadata[0].name
                    key  = "DB_HOSTNAME"
                  }
                }
              }

              env {
                name = "DB_PORT"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.db_secret.metadata[0].name
                    key  = "DB_PORT"
                  }
                }
              }

              env {
                name = "DB_NAME"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.db_secret.metadata[0].name
                    key  = "DB_NAME"
                  }
                }
              }

              env {
                name = "DB_USERNAME"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.db_secret.metadata[0].name
                    key  = "DB_USERNAME"
                  }
                }
              }

              env {
                name = "DB_PASSWORD"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.db_secret.metadata[0].name
                    key  = "DB_PASSWORD"
                  }
                }
              }
            }

            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}