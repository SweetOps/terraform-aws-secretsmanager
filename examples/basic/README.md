## terraform-aws-secretsmanager
Terraform module to provision and manage AWS Secrets Manager.

## Usage

```hcl
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
  source  = "SweetOps/secretsmanager/aws"
  version = "0.1.0"

  secret_version = {
    secret_string = jsonencode(
      {
        ssh_public_key  = base64encode(module.ssh_key_pair.public_key)
        ssh_private_key = base64encode(module.ssh_key_pair.private_key)
      }
    )
  }

  context = module.label.context
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | SweetOps/secretsmanager/aws | ../../ |
| <a name="module_ssh_key_pair"></a> [ssh\_key\_pair](#module\_ssh\_key\_pair) | cloudposse/key-pair/aws | 0.18.1 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS --> 

## License
The Apache-2.0 license