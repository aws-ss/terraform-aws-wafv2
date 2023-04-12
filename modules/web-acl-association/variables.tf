variable "resource_arn" {
  description = " (Required) The Amazon Resource Name (ARN) of the resource to associate with the web ACL."
  type        = string
}

variable "web_acl_arn" {
  description = "(Required) The Amazon Resource Name (ARN) of the Web ACL that you want to associate with the resource."
  type        = string
}