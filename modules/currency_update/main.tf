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
            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}