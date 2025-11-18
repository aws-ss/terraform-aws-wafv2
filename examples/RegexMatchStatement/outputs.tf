output "web_acl_arn" {
  description = "The ARN of the WAFv2 Web ACL"
  value       = module.wafv2.aws_wafv2_arn
}

output "web_acl_id" {
  description = "The ID of the WAFv2 Web ACL"
  value       = module.wafv2.aws_wafv2_id
}

output "web_acl_capacity" {
  description = "The capacity of the WAFv2 Web ACL"
  value       = module.wafv2.aws_wafv2_capacity
}

output "web_acl_rules" {
  description = "The rules configured in the WAFv2 Web ACL"
  value       = module.wafv2.aws_wafv2_rule
}
