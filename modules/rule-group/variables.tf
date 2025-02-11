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

variable "capacity" {
  description = "(Required, Forces new resource) The web ACL capacity units (WCUs) required for this rule group."
  type        = number
}

variable "custom_response_body" {
  description = "(Optional) Defines custom response bodies that can be referenced by custom_response actions."
  type        = map(string)
  default     = {}
}

variable "visibility_config" {
  description = "(Required) Defines and enables Amazon CloudWatch metrics and web request sample collection."
  type        = map(string)
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