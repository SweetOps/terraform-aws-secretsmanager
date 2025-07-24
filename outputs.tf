output "name" {
  value       = local.secret_name
  description = "Name of the secret"
}

output "id" {
  value       = local.secret_id
  description = "ID of the secret"
}

output "arn" {
  value       = local.secret_arn
  description = "ARN of the secret"
}

output "version_id" {
  value       = local.version_id
  description = "The unique identifier of the version of the secret"
}

output "kms_key_arn" {
  value       = module.kms_key.key_arn
  description = "KMS key ARN"
}

output "kms_key_id" {
  value       = local.kms_key_id
  description = "KMS key ID"
}

output "kms_key_alias_arn" {
  value       = module.kms_key.alias_arn
  description = "KMS key alias ARN"
}

output "kms_key_alias_name" {
  value       = module.kms_key.alias_name
  description = "KMS key alias name"
}
