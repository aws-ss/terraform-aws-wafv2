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
      name            = "Rule01"
      priority        = 10
      override_action = "count"
      managed_rule_group_statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        # Deprecated - excluded_rule = ["NoUserAgent_HEADER", "UserAgent_BadBots_HEADER"]

        rule_action_override = [
          {
            name          = "NoUserAgent_HEADER"
            action_to_use = "block"
            custom_response = {
              response_code            = 400
              custom_response_body_key = "CustomResponseBody2"
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
          },
          {
            name          = "UserAgent_BadBots_HEADER"
            action_to_use = "captcha"
          }
        ]

        scope_down_statement = {
          geo_match_statement = {
            country_codes : ["CN"]
            forwarded_ip_config = {
              fallback_behavior = "MATCH"
              header_name       = "X-Forwarded-For"
            }
          }
        }
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
