provider "aws" {
  region = "ap-northeast-2"
}

module "wafv2" {
  source = "../..//"

  name           = "WebACL01"
  scope          = "REGIONAL"
  default_action = "block"
  rule = [
    {
      name     = "Rule01"
      priority = 10
      action   = "block"
      rate_based_statement = {
        limit              = 1000
        aggregate_key_type = "FORWARDED_IP"
        forwarded_ip_config = {
          fallback_behavior = "MATCH"
          header_name       = "X-Forwarded-For"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "cloudwatch_metric_name"
        sampled_requests_enabled   = false
      }
    }
  ]
  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "cloudwatch_metric_name"
    sampled_requests_enabled   = false
  }
  tags = {
    Team : "Security"
    Owner : "Security"
  }
}