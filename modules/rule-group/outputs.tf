output "aws_wafv2_rule_group_arn" {
  description = "The ARN of the WAF rule group."
  value       = aws_wafv2_rule_group.this.arn
}

output "aws_wafv2_id" {
  description = "The ID of the WAF rule group."
  value       = aws_wafv2_rule_group.this.id
}

output "aws_wafv2_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_wafv2_rule_group.this.tags_all
}