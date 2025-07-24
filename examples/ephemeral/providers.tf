provider "aws" {
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    kms            = var.localstack_endpoint
    secretsmanager = var.localstack_endpoint
  }
}
