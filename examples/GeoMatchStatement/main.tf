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
      geo_match_statement = {
        country_codes : ["CN", "US"]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "cloudwatch_metric_name"
        sampled_requests_enabled   = false
      }
    },
    {
      name     = "Rule02"
      priority = 20
      action   = "block"
      geo_match_statement = {
        country_codes : ["AE"]
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