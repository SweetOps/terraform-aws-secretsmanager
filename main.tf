locals {
  enabled                 = module.this.enabled
  secret_name             = one(aws_secretsmanager_secret.default[*].name)
  secret_id               = one(aws_secretsmanager_secret.default[*].id)
  secret_arn              = one(aws_secretsmanager_secret.default[*].arn)
  version_id              = local.enabled && !var.secret_version["ignore_changes_enabled"] ? one(aws_secretsmanager_secret_version.default[*].version_id) : one(aws_secretsmanager_secret_version.ignore_changes[*].version_id)
  secret_rotation_enabled = local.enabled && var.rotation["enabled"]
  kms_key_enabled         = local.enabled && var.kms_key["enabled"]
  kms_key_id              = var.kms_key["enabled"] ? module.kms_key.key_id : var.kms_key_id
}

module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.2"

  description             = var.kms_key["description"]
  deletion_window_in_days = var.kms_key["deletion_window_in_days"]
  enable_key_rotation     = var.kms_key["enable_key_rotation"]
  alias                   = lookup(var.kms_key, "alias", format("secretsmanager/%s", module.this.id))

  enabled = local.kms_key_enabled
  context = module.this.context
}

resource "aws_secretsmanager_secret" "default" {
  count = local.enabled ? 1 : 0

  name                           = module.this.id
  description                    = var.description
  policy                         = var.policy
  tags                           = module.this.tags
  recovery_window_in_days        = var.recovery_window_in_days
  kms_key_id                     = local.kms_key_id
  force_overwrite_replica_secret = var.force_overwrite_replica_secret

  dynamic "replica" {
    for_each = var.replicas

    content {
      kms_key_id = replica.value.kms_key_id
      region     = replica.value.region
    }
  }
}

resource "aws_secretsmanager_secret_version" "default" {
  count = local.enabled && !var.secret_version["ignore_changes_enabled"] ? 1 : 0

  secret_id     = local.secret_id
  secret_string = var.secret_version["secret_string"]
  secret_binary = var.secret_version["secret_binary"]
}

resource "aws_secretsmanager_secret_version" "ignore_changes" {
  count = local.enabled && var.secret_version["ignore_changes_enabled"] ? 1 : 0

  secret_id     = local.secret_id
  secret_string = var.secret_version["secret_string"]
  secret_binary = var.secret_version["secret_binary"]

  lifecycle {
    ignore_changes = [
      secret_string,
      secret_binary,
    ]
  }
}

resource "aws_secretsmanager_secret_rotation" "default" {
  count = local.secret_rotation_enabled ? 1 : 0

  secret_id           = local.secret_id
  rotation_lambda_arn = var.rotation["lambda_arn"]

  rotation_rules {
    automatically_after_days = var.rotation["automatically_after_days"]
    duration                 = var.rotation["duration"]
    schedule_expression      = var.rotation["schedule_expression"]
  }
}
