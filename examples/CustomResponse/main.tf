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
  default_custom_response = {
    response_code            = 418
    custom_response_body_key = "CustomResponseBody1"
    response_header = [
      {
        name  = "X-Teapot-Protocol"
        value = "true"
      }
    ]
  }
  rule = [
    {
      name     = "Rule01"
      priority = 10
      action   = "block"
      custom_response = {
        response_code = 404
        response_header = [
          {
            name  = "X-Custom-Response-Header01"
            value = "Not authorized"
          },
          {
            name  = "X-Custom-Response-Header02"
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

  custom_response_body = [
    {
      key          = "CustomResponseBody1",
      content      = "Not authorized1",
      content_type = "TEXT_PLAIN"
    },
    {
      key          = "CustomResponseBody2",
      content      = "Not authorized2",
      content_type = "TEXT_PLAIN"
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
