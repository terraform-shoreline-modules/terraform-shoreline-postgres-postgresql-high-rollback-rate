resource "shoreline_notebook" "postgresql_high_rollback_rate_incident" {
  name       = "postgresql_high_rollback_rate_incident"
  data       = file("${path.module}/data/postgresql_high_rollback_rate_incident.json")
  depends_on = [shoreline_action.invoke_pg_stat_rollback_rate,shoreline_action.invoke_db_config_optimization]
}

resource "shoreline_file" "pg_stat_rollback_rate" {
  name             = "pg_stat_rollback_rate"
  input_file       = "${path.module}/data/pg_stat_rollback_rate.sh"
  md5              = filemd5("${path.module}/data/pg_stat_rollback_rate.sh")
  description      = "Measure the rollback rate"
  destination_path = "/agent/scripts/pg_stat_rollback_rate.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "db_config_optimization" {
  name             = "db_config_optimization"
  input_file       = "${path.module}/data/db_config_optimization.sh"
  md5              = filemd5("${path.module}/data/db_config_optimization.sh")
  description      = "Optimize the database configuration to reduce the frequency of rollbacks. Adjusting the database settings can help to optimize the rollback rate."
  destination_path = "/agent/scripts/db_config_optimization.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_pg_stat_rollback_rate" {
  name        = "invoke_pg_stat_rollback_rate"
  description = "Measure the rollback rate"
  command     = "`chmod +x /agent/scripts/pg_stat_rollback_rate.sh && /agent/scripts/pg_stat_rollback_rate.sh`"
  params      = []
  file_deps   = ["pg_stat_rollback_rate"]
  enabled     = true
  depends_on  = [shoreline_file.pg_stat_rollback_rate]
}

resource "shoreline_action" "invoke_db_config_optimization" {
  name        = "invoke_db_config_optimization"
  description = "Optimize the database configuration to reduce the frequency of rollbacks. Adjusting the database settings can help to optimize the rollback rate."
  command     = "`chmod +x /agent/scripts/db_config_optimization.sh && /agent/scripts/db_config_optimization.sh`"
  params      = ["DATABASE_PASSWORD","DATABASE_NAME","DATABASE_HOST","DATABASE_PORT"]
  file_deps   = ["db_config_optimization"]
  enabled     = true
  depends_on  = [shoreline_file.db_config_optimization]
}

