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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_secrets"></a> [secrets](#module\_secrets) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_localstack_endpoint"></a> [localstack\_endpoint](#input\_localstack\_endpoint) | LocalStack Endpoint | `string` | `"http://localhost:4566"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the secret |
| <a name="output_id"></a> [id](#output\_id) | ID of the secret |
| <a name="output_kms_key_alias_arn"></a> [kms\_key\_alias\_arn](#output\_kms\_key\_alias\_arn) | KMS key alias ARN |
| <a name="output_kms_key_alias_name"></a> [kms\_key\_alias\_name](#output\_kms\_key\_alias\_name) | KMS key alias name |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS key ARN |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | KMS key ID |
| <a name="output_name"></a> [name](#output\_name) | Name of the secret |
| <a name="output_version_id"></a> [version\_id](#output\_version\_id) | The unique identifier of the version of the secret. |
<!-- END_TF_DOCS --> 

## License
The Apache-2.0 license