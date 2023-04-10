variable "name" {
  description = "(Required) A friendly name of the IP set."
  type        = string
}

variable "description" {
  description = "(Optional) A friendly description of the IP set."
  type        = string
  default     = null
}

variable "scope" {
  description = "(Required) Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL."
  type        = string
}

variable "ip_address_version" {
  description = "(Required) Specify IPV4 or IPV6. Valid values are IPV4 or IPV6."
  type        = string
}

variable "addresses" {
  description = "(Required) Contains an array of strings that specify one or more IP addresses or blocks of IP addresses in Classless Inter-Domain Routing (CIDR) notation. AWS WAF supports all address ranges for IP versions IPv4 and IPv6."
  type        = list(string)
}

variable "tags" {
  description = "Mapping of additional tags for resource."
  type        = map(string)
  default     = null
}