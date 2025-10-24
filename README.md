# terraform-aws-wafv2

A Terraform module that creates Web Application Firewall (WAFV2).

## Available Features

- Associate WebACL with one (ALB, API Gateway, Cognito User Pool)
- Create IPSets
- Create a WAFv2 Rule Group resource
- Custom Response Body
- Logging Configuration
- Statements
  - AndStatement
  - AsnMatchStatement
  - ByteMatchStatement
  - GeoMatchStatement
  - IPSetReferenceStatement
  - LabelMatchStatement
  - ManagedRuleGroupStatement
    - AWSManagedRulesACFPRuleSet
    - AWSManagedRulesATPRuleSet
    - AWSManagedRulesBotControlRuleSet
    - AWSManagedRulesAntiDDoSRuleSet
  - NotStatement
  - OrStatement
  - RateBasedStatement
  - RegexPatternSetStatement
  - SizeConstraintStatement
  - SqliMatchStatement
  - XssMatchStatement

## Examples

- See [Example Codes](https://github.com/aws-ss/terraform-aws-wafv2/tree/main/examples) for full details.

## Tests

This module has unit tests.
To run them, do:

```shell
terraform test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.82.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.62.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_captcha_config"></a> [captcha\_config](#input\_captcha\_config) | (Optional) The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300. | `number` | `300` | no |
| <a name="input_challenge_config"></a> [challenge\_config](#input\_challenge\_config) | (Optional) The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300. | `number` | `300` | no |
| <a name="input_custom_response_body"></a> [custom\_response\_body](#input\_custom\_response\_body) | (Optional) Defines custom response bodies that can be referenced by custom\_response actions. | `map(any)` | `{}` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | (Required) Action to perform if none of the rules contained in the WebACL match. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Friendly description of the WebACL. | `string` | `null` | no |
| <a name="input_enabled_logging_configuration"></a> [enabled\_logging\_configuration](#input\_enabled\_logging\_configuration) | (Optional) Whether to create logging configuration. | `bool` | `false` | no |
| <a name="input_enabled_web_acl_association"></a> [enabled\_web\_acl\_association](#input\_enabled\_web\_acl\_association) | (Optional) Whether to create ALB association with WebACL. | `bool` | `true` | no |
| <a name="input_log_destination_configs"></a> [log\_destination\_configs](#input\_log\_destination\_configs) | (Required) The Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket Amazon Resource Names (ARNs) that you want to associate with the web ACL. | `string` | `null` | no |
| <a name="input_logging_filter"></a> [logging\_filter](#input\_logging\_filter) | (Optional) A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation. | `any` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Friendly name of the WebACL. | `string` | n/a | yes |
| <a name="input_redacted_fields"></a> [redacted\_fields](#input\_redacted\_fields) | (Optional) The parts of the request that you want to keep out of the logs. Up to 100 redacted\_fields blocks are supported. | `map(any)` | `null` | no |
| <a name="input_resource_arn"></a> [resource\_arn](#input\_resource\_arn) | (Required) The Amazon Resource Name (ARN) of the resource to associate with the web ACL. | `list(string)` | n/a | yes |
| <a name="input_rule"></a> [rule](#input\_rule) | (Optional) Rule blocks used to identify the web requests that you want to allow, block, or count. | `any` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | (Required) Specifies whether this is for an AWS CloudFront distribution or for a regional application | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Map of key-value pairs to associate with the resource. | `map(string)` | `null` | no |
| <a name="input_token_domains"></a> [token\_domains](#input\_token\_domains) | (Optional) Specifies the domains that AWS WAF should accept in a web request token. This enables the use of tokens across multiple protected websites. When AWS WAF provides a token, it uses the domain of the AWS resource that the web ACL is protecting. If you don't specify a list of token domains, AWS WAF accepts tokens only for the domain of the protected resource. With a token domain list, AWS WAF accepts the resource's host domain plus all domains in the token domain list, including their prefixed subdomains. | `list(string)` | `[]` | no |
| <a name="input_visibility_config"></a> [visibility\_config](#input\_visibility\_config) | (Required) Defines and enables Amazon CloudWatch metrics and web request sample collection. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_wafv2_arn"></a> [aws\_wafv2\_arn](#output\_aws\_wafv2\_arn) | The ARN of the WAF WebACL. |
| <a name="output_aws_wafv2_capacity"></a> [aws\_wafv2\_capacity](#output\_aws\_wafv2\_capacity) | Web ACL capacity units (WCUs) currently being used by this web ACL. |
| <a name="output_aws_wafv2_id"></a> [aws\_wafv2\_id](#output\_aws\_wafv2\_id) | The ID of the WAF WebACL. |
| <a name="output_aws_wafv2_tags_all"></a> [aws\_wafv2\_tags\_all](#output\_aws\_wafv2\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_aws_wafv2_web_acl_logging_configuration_id"></a> [aws\_wafv2\_web\_acl\_logging\_configuration\_id](#output\_aws\_wafv2\_web\_acl\_logging\_configuration\_id) | The Amazon Resource Name (ARN) of the WAFv2 Web ACL. |
<!-- END_TF_DOCS -->
