<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_ip_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addresses"></a> [addresses](#input\_addresses) | (Required) Contains an array of strings that specify one or more IP addresses or blocks of IP addresses in Classless Inter-Domain Routing (CIDR) notation. AWS WAF supports all address ranges for IP versions IPv4 and IPv6. | `list(string)` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) A friendly description of the IP set. | `string` | n/a | yes |
| <a name="input_ip_address_version"></a> [ip\_address\_version](#input\_ip\_address\_version) | (Required) Specify IPV4 or IPV6. Valid values are IPV4 or IPV6. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) A friendly name of the IP set. | `string` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | (Required) Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Mapping of additional tags for resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_wafv2_ip_set_arn"></a> [aws\_wafv2\_ip\_set\_arn](#output\_aws\_wafv2\_ip\_set\_arn) | The Amazon Resource Name (ARN) that identifies the cluster. |
| <a name="output_aws_wafv2_ip_set_id"></a> [aws\_wafv2\_ip\_set\_id](#output\_aws\_wafv2\_ip\_set\_id) | A unique identifier for the set |
| <a name="output_aws_wafv2_ip_set_tags_all"></a> [aws\_wafv2\_ip\_set\_tags\_all](#output\_aws\_wafv2\_ip\_set\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
<!-- END_TF_DOCS -->