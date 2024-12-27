provider "aws" {
  region = "ap-northeast-2"
}

module "wafv2" {
  source = "../..//"

  enabled_web_acl_association = true
  resource_arn                = []

  enabled_logging_configuration = false

  name           = "WebACL01"
  scope          = "REGIONAL"
  default_action = "block"
  rule = [
    {
      name     = "Rule01"
      priority = 10
      action   = "block"
      rate_based_statement = {
        limit                 = 1000
        aggregate_key_type    = "FORWARDED_IP"
        evaluation_window_sec = 120
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