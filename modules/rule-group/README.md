<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.51.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.51.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_rule_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_capacity"></a> [capacity](#input\_capacity) | (Required, Forces new resource) The web ACL capacity units (WCUs) required for this rule group. | `number` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Friendly description of the WebACL. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Friendly name of the WebACL. | `string` | n/a | yes |
| <a name="input_rule"></a> [rule](#input\_rule) | (Optional) Rule blocks used to identify the web requests that you want to allow, block, or count. | `any` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | (Required) Specifies whether this is for an AWS CloudFront distribution or for a regional application | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of key-value pairs to associate with the resource. | `map(string)` | `null` | no |
| <a name="input_visibility_config"></a> [visibility\_config](#input\_visibility\_config) | (Required) Defines and enables Amazon CloudWatch metrics and web request sample collection. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_wafv2_id"></a> [aws\_wafv2\_id](#output\_aws\_wafv2\_id) | The ID of the WAF rule group. |
| <a name="output_aws_wafv2_rule_group_arn"></a> [aws\_wafv2\_rule\_group\_arn](#output\_aws\_wafv2\_rule\_group\_arn) | The ARN of the WAF rule group. |
| <a name="output_aws_wafv2_tags_all"></a> [aws\_wafv2\_tags\_all](#output\_aws\_wafv2\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
<!-- END_TF_DOCS -->