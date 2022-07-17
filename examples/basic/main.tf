module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name      = "alpha"
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

module "secrets" {
  source = "../../"

  secret_version = {
    enabled = true
    secret_string = jsonencode(
      {
        ssh_public_key  = base64encode(module.ssh_key_pair.public_key)
        ssh_private_key = base64encode(module.ssh_key_pair.private_key)
      }
    )
  }
  context = module.label.context
}
