output "aws_wafv2_ip_set_id" {
  description = "A unique identifier for the set"
  value       = aws_wafv2_ip_set.this.id
}

output "aws_wafv2_ip_set_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster."
  value       = aws_wafv2_ip_set.this.arn
}

output "aws_wafv2_ip_set_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_wafv2_ip_set.this.tags_all
}