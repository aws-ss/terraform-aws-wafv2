variable "log_destination_configs" {
  type        = string
  description = "(Required) The Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket Amazon Resource Names (ARNs) that you want to associate with the web ACL."
}

variable "resource_arn" {
  type        = string
  description = "(Required) The Amazon Resource Name (ARN) of the web ACL that you want to associate with log_destination_configs."
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