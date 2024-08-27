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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.16 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.16 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | cloudposse/kms-key/aws | 0.12.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_rotation.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_secretsmanager_secret_version.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.ignore_changes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the secret. | `string` | `"Managed by Terraform"` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_force_overwrite_replica_secret"></a> [force\_overwrite\_replica\_secret](#input\_force\_overwrite\_replica\_secret) | Whether to overwrite a secret with the same name in the destination Region. | `bool` | `true` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_kms_key"></a> [kms\_key](#input\_kms\_key) | enabled:<br>    Whether to create KSM key.<br>description:<br>    The description of the key as viewed in AWS console.<br>alias:<br>    The display name of the alias. The name must start with the word alias followed by a forward slash. <br>    If not specified, the alias name will be auto-generated.<br>deletion\_window\_in\_days:<br>    Duration in days after which the key is deleted after destruction of the resource<br>enable\_key\_rotation:<br>    Specifies whether key rotation is enabled. | <pre>object({<br>    enabled                 = optional(bool, true)<br>    description             = optional(string, "Managed by Terraform")<br>    alias                   = optional(string)<br>    deletion_window_in_days = optional(number, 30)<br>    enable_key_rotation     = optional(bool, true)<br>  })</pre> | `{}` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN or Id of the AWS KMS customer master key (CMK) to be used to encrypt the secret values in the versions stored in this secret. <br>If you don't specify this value, then Secrets Manager defaults to using the AWS account's default CMK (the one named `aws/secretsmanager`). | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Valid JSON document representing a resource policy. | `string` | `null` | no |
| <a name="input_recovery_window_in_days"></a> [recovery\_window\_in\_days](#input\_recovery\_window\_in\_days) | Valid JSON document representing a resource policy. | `number` | `30` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | kms\_key\_id:<br>    ARN, Key ID, or Alias of the AWS KMS key within the region secret is replicated to.<br>region:<br>    Region for replicating the secret. | <pre>list(<br>    object(<br>      {<br>        kms_key_id = string<br>        region     = string<br>      }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_rotation"></a> [rotation](#input\_rotation) | enabled:<br>    Whether to create secret rotation rule. <br>    Default value: `false`<br>lambda\_arn:<br>    Specifies the ARN of the Lambda function that can rotate the secret.<br>automatically\_after\_days:<br>    Specifies the number of days between automatic scheduled rotations of the secret.<br>duration:<br>    The length of the rotation window in hours. For example, `3h` for a three hour window.<br>schedule\_expression:<br>    A `cron()` or `rate()` expression that defines the schedule for rotating your secret. Either `automatically_after_days` or `schedule_expression` must be specified. | <pre>object({<br>    enabled                  = optional(bool, false)<br>    lambda_arn               = string<br>    automatically_after_days = optional(number, null)<br>    duration                 = optional(string, null)<br>    schedule_expression      = optional(string, null)<br>  })</pre> | <pre>{<br>  "lambda_arn": ""<br>}</pre> | no |
| <a name="input_secret_version"></a> [secret\_version](#input\_secret\_version) | ignore\_changes\_enabled:<br>    Whether to ignore changes in `secret_string` and `secret_binary`.<br>    Default value: `false`<br>secret\_string:<br>    Specifies text data that you want to encrypt and store in this version of the secret. <br>    This is required if `secret_binary` is not set.<br>secret\_binary:<br>    Specifies binary data that you want to encrypt and store in this version of the secret. <br>    This is required if `secret_string` is not set. <br>    Needs to be encoded to base64. | <pre>object({<br>    secret_string          = optional(string, "{}")<br>    secret_binary          = optional(string)<br>    ignore_changes_enabled = optional(bool, false)<br>  })</pre> | `{}` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

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