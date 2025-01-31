resource "kubernetes_secret" "db_secret" {
  metadata {
    name = "db-secret"
  }

  data = {
    DB_HOSTNAME = base64encode("postgres.database.svc.cluster.local")
    DB_PORT     = var.db_port
    DB_NAME     = var.db_name
    DB_USERNAME = var.db_username
    DB_PASSWORD = var.db_password
  }
}