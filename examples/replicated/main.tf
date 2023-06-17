provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

provider "aws" {
  region = "us-east-2"
  alias  = "ohio"
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name      = "replicated"
  namespace = "so"
  stage     = "staging"
}

module "ssh_key_pair" {
  source  = "cloudposse/key-pair/aws"
  version = "0.18.1"

  ssh_public_key_path = "keys/"
  generate_ssh_key    = "true"

  context = module.label.context
}

module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  multi_region = true

  context = module.label.context
}

resource "aws_kms_replica_key" "virginia" {
  provider = aws.virginia

  description             = "Multi-Region replica key"
  deletion_window_in_days = 7
  primary_key_arn         = module.kms_key.key_arn
}

resource "aws_kms_replica_key" "ohio" {
  provider = aws.ohio

  description             = "Multi-Region replica key"
  deletion_window_in_days = 7
  primary_key_arn         = module.kms_key.key_arn
}

module "secrets" {
  source = "../../"

  secret_version = {
    secret_string = jsonencode(
      {
        ssh_public_key  = base64encode(module.ssh_key_pair.public_key)
        ssh_private_key = base64encode(module.ssh_key_pair.private_key)
      }
    )
  }

  recovery_window_in_days = 0
  kms_key_id              = module.kms_key.key_id

  kms_key = {
    enabled = false
  }

  replicas = [
    {
      region     = "us-east-1"
      kms_key_id = aws_kms_replica_key.virginia.key_id
    },
    {
      region     = "us-east-2"
      kms_key_id = aws_kms_replica_key.ohio.key_id
    }
  ]

  context = module.label.context
}
