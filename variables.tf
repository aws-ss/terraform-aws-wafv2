variable "name" {
  description = "(Required) Friendly name of the WebACL."
  type        = string
}

variable "description" {
  description = "(Optional) Friendly description of the WebACL."
  type        = string
  default     = null
}

variable "scope" {
  description = "(Required) Specifies whether this is for an AWS CloudFront distribution or for a regional application"
  type        = string
}

variable "default_action" {
  description = "(Required) Action to perform if none of the rules contained in the WebACL match."
  type        = string
}

variable "default_custom_response" {
  description = "(Optional) Customise the response when the default action is block"
  type = object({
    response_code            = optional(number, 403)
    custom_response_body_key = optional(string)
    response_header          = optional(list(object({
      name  = string
      value = string
    })))
  })
  default = null
}

variable "association_config" {
  description = "(Optional) Customizes the request body that your protected resource forward to AWS WAF for inspection."
  type        = map(any)
  default     = null
}

variable "visibility_config" {
  description = "(Required) Defines and enables Amazon CloudWatch metrics and web request sample collection."
  type        = map(string)
}

variable "custom_response_body" {
  description = "(Optional) Defines custom response bodies that can be referenced by custom_response actions."
  type = list(object({
    content      = string
    content_type = string
    key          = string
  }))
  default = []
}

variable "captcha_config" {
  description = "(Optional) The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300."
  type        = number
  default     = 300
}

variable "challenge_config" {
  description = "(Optional) The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300."
  type        = number
  default     = 300
}

variable "token_domains" {
  description = "(Optional) Specifies the domains that AWS WAF should accept in a web request token. This enables the use of tokens across multiple protected websites. When AWS WAF provides a token, it uses the domain of the AWS resource that the web ACL is protecting. If you don't specify a list of token domains, AWS WAF accepts tokens only for the domain of the protected resource. With a token domain list, AWS WAF accepts the resource's host domain plus all domains in the token domain list, including their prefixed subdomains."
  type        = list(string)
  default     = []
}

variable "rule" {
  description = <<-EOF
    (Optional) A list of rule objects.
    Currently untyped. Typable, but it would take around 8000 lines of object definition!
    The objects it supports look rather like the objects supported by the [AWS API](https://docs.aws.amazon.com/waf/latest/APIReference/API_Rule.html).

    Each rule supports the following keys:

    ```
      name            = string
      priority        = number
      action_override = optional(string) # required for managed_rule_group_statements
      action          = optional(string) # required for other kinds of statements 
      # Custom response configuration for block actions
      custom_response = optional(object({
        custom_response_body_key = optional(string)
        response_code            = optional(number)
        response_header = optional(list(object({
          name  = string
          value = string
        })), [])
      }))
      # Rule labels
      rule_label = optional(list(object({
        name = string
      })))
      # Visibility configuration
      visibility_config = object({
        cloudwatch_metrics_enabled = bool
        metric_name                = string
        sampled_requests_enabled   = bool
      })
    ```

    It also supports most, if not all, of the WAFv2 [Statements](https://docs.aws.amazon.com/waf/latest/APIReference/API_Statement.html).
    Each of these are introduced with one of the following `statement_type` keys:

    - asn_match_statement
    - byte_match_statement
    - geo_match_statement
    - ip_set_reference_statement
    - label_match_statement
    - managed_rule_group_statement
    - rate_based_statement
    - regex_match_statement
    - regex_pattern_set_reference_statement
    - rule_group_reference_statement
    - size_constraint_statement
    - sqli_match_statement
    - xss_match_statement

    `managed_rule_group_statement`s and `rule_group_reference_statement`s cannot be nested in not_statements
    Other rule types can be.
    
    `and_statement`s and `or_statement`s contain a `statements` list.
    All of the above types of rule, including `not_statement`s, can be nested in these.
    Neither `and_statement`s nor `or_statement`s can be nested within `and_statement`s or `or_statement`s

    Each rule can define only one type of statement.

    Rules are given priorities based on their list order.

    See this module's examples for more details.
  EOF
  type        = any
  default     = []
}

variable "tags" {
  description = "(Optional) Map of key-value pairs to associate with the resource."
  type        = map(string)
  default     = null
}

variable "enabled_web_acl_association" {
  description = "(Optional) Whether to create ALB association with WebACL."
  type        = bool
  default     = true
}

variable "resource_arn" {
  description = " (Required) The Amazon Resource Name (ARN) of the resource to associate with the web ACL."
  type        = list(string)
}

variable "enabled_logging_configuration" {
  description = "(Optional) Whether to create logging configuration."
  type        = bool
  default     = false
}

variable "log_destination_configs" {
  type        = string
  description = "(Required) The Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket Amazon Resource Names (ARNs) that you want to associate with the web ACL."
  default     = null
}

variable "redacted_fields" {
  type        = list(any)
  description = "(Optional) The parts of the request that you want to keep out of the logs. Up to 100 redacted_fields blocks are supported."
  default     = null
}

variable "logging_filter" {
  type        = any
  description = "(Optional) A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation."
  default     = null
}
