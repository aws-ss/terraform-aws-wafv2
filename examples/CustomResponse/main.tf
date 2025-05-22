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
      custom_response = {
        response_code = 404
        response_header = [
          {
            name  = "X-Custom-Response-Header-01"
            value = "Not authorized"
          }
        ]
      }
      geo_match_statement = {
        country_codes : ["CN", "US"]
      }
      visibility_config = {
        cloudwatch_metrics_enabled = false
        metric_name                = "cloudwatch_metric_name"
        sampled_requests_enabled   = false
      }
    }
  ]

  custom_response_body = {
    "CustomResponseBody" = {
      content      = "Not authorized",
      content_type = "TEXT_PLAIN"
    }
  }

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