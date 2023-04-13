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
| [aws_wafv2_web_acl_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_log_destination_configs"></a> [log\_destination\_configs](#input\_log\_destination\_configs) | (Required) The Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket Amazon Resource Names (ARNs) that you want to associate with the web ACL. | `string` | n/a | yes |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | (Optional) A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation. | `any` | `null` | no |
| <a name="input_redacted_fields"></a> [redacted\_fields](#input\_redacted\_fields) | (Optional) The parts of the request that you want to keep out of the logs. Up to 100 redacted\_fields blocks are supported. | `map(any)` | `null` | no |
| <a name="input_resource_arn"></a> [resource\_arn](#input\_resource\_arn) | (Required) The Amazon Resource Name (ARN) of the web ACL that you want to associate with log\_destination\_configs. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_wafv2_web_acl_logging_configuration_id"></a> [aws\_wafv2\_web\_acl\_logging\_configuration\_id](#output\_aws\_wafv2\_web\_acl\_logging\_configuration\_id) | The Amazon Resource Name (ARN) of the WAFv2 Web ACL. |
<!-- END_TF_DOCS -->