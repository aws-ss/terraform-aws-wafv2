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
      action   = "count"
      byte_match_statement = {
        field_to_match = {
          single_header = {
            name = "host"
          }
        }
        positional_constraint = "EXACTLY"
        search_string         = "test"
        text_transformation = {
          priority = 20
          type     = "NONE"
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