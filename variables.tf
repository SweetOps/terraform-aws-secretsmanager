variable "description" {
  type        = string
  default     = "Managed by Terraform"
  description = "Description of the secret."
}

variable "policy" {
  type        = string
  default     = null
  description = "Valid JSON document representing a resource policy."
}

variable "recovery_window_in_days" {
  type        = number
  default     = 30
  description = "Valid JSON document representing a resource policy."
}

variable "force_overwrite_replica_secret" {
  type        = bool
  default     = true
  description = "Whether to overwrite a secret with the same name in the destination Region."
}

variable "replicas" {
  type = list(
    object(
      {
        kms_key_id = string
        region     = string
      }
    )
  )
  default     = []
  description = <<-DOC
    kms_key_id:
        ARN, Key ID, or Alias of the AWS KMS key within the region secret is replicated to.
    region:
        Region for replicating the secret.
  DOC
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = <<-DOC
    ARN or Id of the AWS KMS customer master key (CMK) to be used to encrypt the secret values in the versions stored in this secret. 
    If you don't specify this value, then Secrets Manager defaults to using the AWS account's default CMK (the one named `aws/secretsmanager`). 
  DOC
}

variable "kms_key" {
  type = object({
    enabled                 = optional(bool, true)
    description             = optional(string, "Managed by Terraform")
    alias                   = optional(string)
    deletion_window_in_days = optional(number, 30)
    enable_key_rotation     = optional(bool, true)
  })
  default     = {}
  description = <<-DOC
    enabled:
        Whether to create KSM key.
    description:
        The description of the key as viewed in AWS console.
    alias:
        The display name of the alias. The name must start with the word alias followed by a forward slash. 
        If not specified, the alias name will be auto-generated.
    deletion_window_in_days:
        Duration in days after which the key is deleted after destruction of the resource
    enable_key_rotation:
        Specifies whether key rotation is enabled.
  DOC
}

variable "secret_version" {
  type = object(
    {
      secret_string     = optional(string, "{}")
      secret_binary     = optional(string)
      ephemeral         = optional(bool, false)
      ephemeral_version = optional(number, 0)
    }
  )
  sensitive   = true
  default     = {}
  description = <<-DOC
    secret_string:
        Specifies text data that you want to encrypt and store in this version of the secret. 
        This is required if `secret_binary` is not set.
    secret_binary:
        Specifies binary data that you want to encrypt and store in this version of the secret. 
        This is required if `secret_string` is not set. 
        Needs to be encoded to base64.
    ephemeral:
        Whether to create an ephemeral secret version.
    ephemeral_version:
        If `ephemeral` is set to `true`, increment this value when an update is made to the secret version.
  DOC
}

variable "rotation" {
  type = object({
    enabled                  = optional(bool, false)
    lambda_arn               = string
    automatically_after_days = optional(number, null)
    duration                 = optional(string, null)
    schedule_expression      = optional(string, null)
  })
  default = {
    lambda_arn = ""
  }
  description = <<-DOC
    enabled:
        Whether to create secret rotation rule. 
        Default value: `false`
    lambda_arn:
        Specifies the ARN of the Lambda function that can rotate the secret.
    automatically_after_days:
        Specifies the number of days between automatic scheduled rotations of the secret.
    duration:
        The length of the rotation window in hours. For example, `3h` for a three hour window.
    schedule_expression:
        A `cron()` or `rate()` expression that defines the schedule for rotating your secret. Either `automatically_after_days` or `schedule_expression` must be specified.
  DOC
}
