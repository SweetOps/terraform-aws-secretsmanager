module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name       = "alpha"
  namespace  = "so"
  stage      = "staging"
  attributes = var.attributes
}

module "secrets" {
  source = "../../"

  secret_version = {
    secret_string = jsonencode(
      {
        secret_foo = "foo"
        secret_bar = "bar"
      }
    )
  }
  recovery_window_in_days = 0
  context                 = module.label.context
}

output "name" {
  value       = module.secrets.name
  description = "Name of the secret"
}

output "id" {
  value       = module.secrets.id
  description = "ID of the secret"
}

output "arn" {
  value       = module.secrets.arn
  description = "ARN of the secret"
}

output "version_id" {
  value       = module.secrets.version_id
  description = "The unique identifier of the version of the secret."
}

output "kms_key_arn" {
  value       = module.secrets.kms_key_arn
  description = "KMS key ARN"
}

output "kms_key_id" {
  value       = module.secrets.kms_key_id
  description = "KMS key ID"
}

output "kms_key_alias_arn" {
  value       = module.secrets.kms_key_alias_arn
  description = "KMS key alias ARN"
}

output "kms_key_alias_name" {
  value       = module.secrets.kms_key_alias_name
  description = "KMS key alias name"
}
