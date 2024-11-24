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
                    name = var.config_map_name
                    key  = "CURRENCY_EXCHANGE_URI"
                  }
                }
              }

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
            }

            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}