output "aws_wafv2_arn" {
  description = "The ARN of the WAF WebACL."
  value       = aws_wafv2_web_acl.this.arn
}

output "aws_wafv2_capacity" {
  description = "Web ACL capacity units (WCUs) currently being used by this web ACL."
  value       = aws_wafv2_web_acl.this.capacity
}

output "aws_wafv2_custom_response_body" {
  description = "The custom response body configuration of the WAF WebACL."
  value       = aws_wafv2_web_acl.this.custom_response_body
}

output "aws_wafv2_default_action" {
  description = "The default action of the WAF WebACL."
  value       = aws_wafv2_web_acl.this.default_action
}

output "aws_wafv2_id" {
  description = "The ID of the WAF WebACL."
  value       = aws_wafv2_web_acl.this.id
}

output "aws_wafv2_name" {
  description = "The name of the WAF WebACL."
  value       = aws_wafv2_web_acl.this.name
}

output "aws_wafv2_rule" {
  description = "The rules configuration of the WAF WebACL."
  value       = aws_wafv2_web_acl.this.rule
}

output "aws_wafv2_scope" {
  description = "The scope of the WAF WebACL."
  value       = aws_wafv2_web_acl.this.scope
}

output "aws_wafv2_tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_wafv2_web_acl.this.tags_all
}

output "aws_wafv2_visibility_config" {
  description = "The visibility configuration of the WAF WebACL."
  value       = aws_wafv2_web_acl.this.visibility_config
}

output "aws_wafv2_web_acl_logging_configuration_id" {
  description = "The Amazon Resource Name (ARN) of the WAFv2 Web ACL."
  value       = aws_wafv2_web_acl_logging_configuration.this[*].id
}