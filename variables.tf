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

variable "visibility_config" {
  description = "(Required) Defines and enables Amazon CloudWatch metrics and web request sample collection."
  type        = map(string)
}

variable "custom_response_body" {
  description = "(Optional) Defines custom response bodies that can be referenced by custom_response actions."
  type        = map(any)
  default     = {}
}

variable "rule" {
  description = "(Optional) Rule blocks used to identify the web requests that you want to allow, block, or count."
  type        = any
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
  type        = map(any)
  description = "(Optional) The parts of the request that you want to keep out of the logs. Up to 100 redacted_fields blocks are supported."
  default     = null
}

variable "logging_filter" {
  type        = any
  description = "(Optional) A configuration block that specifies which web requests are kept in the logs and which are dropped. You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation."
  default     = null
}