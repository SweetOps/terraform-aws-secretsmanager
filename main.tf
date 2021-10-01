locals {
  enabled                 = module.this.enabled
  secret_id               = one(aws_secretsmanager_secret.default[*].id)
  secret_arn              = one(aws_secretsmanager_secret.default[*].arn)
  version_id              = one(aws_secretsmanager_secret_version.default[*].version_id)
  secret_version          = defaults(var.secret_version, local.secret_version_default)
  secret_version_enabled  = local.enabled && local.secret_version["enabled"]
  secret_string           = local.secret_version_enabled && length(local.secret_version["secret_string"]) > 0 ? local.secret_version["secret_string"] : null
  secret_binary           = local.secret_version_enabled && length(local.secret_version["secret_binary"]) > 0 ? local.secret_version["secret_binary"] : null
  secret_rotation         = defaults(var.rotation, local.secret_rotation_default)
  secret_rotation_enabled = local.enabled && local.secret_rotation["enabled"]
  kms_key                 = defaults(var.kms_key, local.kms_key_default)
  kms_key_enabled         = local.enabled && local.kms_key["enabled"]
  kms_key_id              = local.kms_key["enabled"] ? module.kms_key.key_id : var.kms_key_id

  kms_key_default = {
    deletion_window_in_days = 30
    description             = "Managed by Terraform"
    enable_key_rotation     = true
    enabled                 = true
  }
  secret_version_default = {
    secret_string = ""
    secret_binary = ""
    enabled       = false
  }

  secret_rotation_default = {
    enabled = false
  }
}

module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.11.0"

  description             = local.kms_key["description"]
  deletion_window_in_days = local.kms_key["deletion_window_in_days"]
  enable_key_rotation     = local.kms_key["enable_key_rotation"]
  alias                   = lookup(local.kms_key, "alias", format("secretsmanager/%s", module.this.id))

  enabled = local.kms_key_enabled
  context = module.this.context
}

resource "aws_secretsmanager_secret" "default" {
  count = local.enabled ? 1 : 0

  name                    = module.this.id
  description             = var.description
  policy                  = var.policy
  tags                    = module.this.tags
  recovery_window_in_days = var.recovery_window_in_days
  kms_key_id              = local.kms_key_id
}

resource "aws_secretsmanager_secret_version" "default" {
  count = local.secret_version_enabled ? 1 : 0

  secret_id     = local.secret_id
  secret_string = local.secret_string
  secret_binary = local.secret_binary
}

resource "aws_secretsmanager_secret_rotation" "default" {
  count = local.secret_rotation_enabled ? 1 : 0

  secret_id           = local.secret_id
  rotation_lambda_arn = var.rotation["lambda_arn"]

  rotation_rules {
    automatically_after_days = var.rotation["automatically_after_days"]
  }
}
